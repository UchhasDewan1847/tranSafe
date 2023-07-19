import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Screen3 extends StatefulWidget {
  @override
  _Screen3State createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  LatLng? currentLocation;
  Set<Marker> markers = {};
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _requestLocationPermissions();
    _fetchEmergencyContact();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLocation!,
        ),
      );
    });
  }

  Future<void> _requestLocationPermissions() async {
    final PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      // Location permissions are denied, display an error message or request user to grant permissions
    }
  }

  Future<void> _sendLocationInformation() async {
    if (currentLocation != null && phoneNumber.isNotEmpty) {
      String locationInformation =
          'Latitude: ${currentLocation!.latitude}\nLongitude: ${currentLocation!.longitude}';

      try {
        await sendSMS(message: locationInformation, recipients: [phoneNumber]);
        print('Location information sent successfully');
      } catch (e) {
        print('Failed to send location information');
      }
    }
  }

  Future<void> _fetchEmergencyContact() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        String emergencyContact = userData['emergencyContact'];
        setState(() {
          phoneNumber = emergencyContact;
          print('the phone number is');
          print(phoneNumber);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          if (currentLocation != null)
            Text(
              'Latitude: ${currentLocation!.latitude}\nLongitude: ${currentLocation!.longitude}',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _sendLocationInformation,
            child: Text('Send Location Information'),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(23.6, 90.0),
                zoom: 14,
              ),
              markers: markers,
              onMapCreated: (GoogleMapController controller) {
                _getCurrentLocation();
              },
            ),
          ),
        ],
      ),
    );
  }
}
