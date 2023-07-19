import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverVerificationScreen extends StatefulWidget {
  @override
  _DriverVerificationScreenState createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isVerified = false;
  List<String>? _verifiedDriversList;

  @override
  void initState() {
    super.initState();
    _fetchVerifiedDriversList();
  }

  Future<void> _fetchVerifiedDriversList() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('verifiedDrivers')
        .doc('Znh09iy8QArzksM5Pe42')
        .get();

    final data = snapshot.data();
    if (data != null && data.containsKey('list')) {
      _verifiedDriversList = List<String>.from(data['list'] as List<dynamic>)
          .map((driverId) => driverId.trim())
          .toList();
      print("Verified Drivers List: $_verifiedDriversList");
    } else {
      print("Verified Drivers List is null or list field is missing");
    }
  }



  Future<bool> _checkVerification(String input) async {
    if (_verifiedDriversList == null) {
      return false;
    }

    print("Submitting verification for input: $input");
    print("Input: ${input.trim()}");
    print("Verified Drivers List: $_verifiedDriversList");

    final cleanInput = input.trim();

    for (var driverId in _verifiedDriversList!) {
      print("Comparing: $driverId == $cleanInput");
      if (driverId == cleanInput) {
        return true;
      }
    }

    return false;
  }


  void _submitVerification() async {
    final input = _inputController.text.trim();
    print("Submitting verification for input: $input");

    if (input.isNotEmpty) {
      final isVerified = await _checkVerification(input);
      print('isVerified: $isVerified');

      setState(() {
        _isVerified = isVerified;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Driver Verification',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  labelText: 'Enter Driver ID',
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitVerification,
              child: Text('Verify'),
            ),
            SizedBox(height: 16),
            if (_isVerified)
              Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Driver Verified!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
