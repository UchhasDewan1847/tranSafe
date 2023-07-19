import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:transafe/screens/authentication_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}
class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _driverLicenseController = TextEditingController();

  int _startIndex = 0;
  int _rowsPerPage = 5;
  bool _reverseOrder = false;
  String _profilePictureUrl = '';
  String? _userType;
  List<dynamic> _tripHistory = [];
  int? _rideCount;
  double? _aggressiveRate = null;
  dynamic? _rating = null;
  List<String> _selectedVehicleTypes = [];

  @override
  void initState() {
    super.initState();
    _fetchAccountData();
  }

  void _fetchAccountData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      if (userSnapshot.exists) {
        String userType = userSnapshot.get('userType');

        if (userType == 'Driver') {
          userSnapshot = await FirebaseFirestore.instance.collection('drivers')
              .doc(user.uid)
              .get();
        }
        else {
          userSnapshot =
          await FirebaseFirestore.instance.collection('passengers').doc(
              user.uid).get();
        }
      }

      setState(() {
        _nameController.text = userSnapshot['name'];
        _emailController.text = userSnapshot['email'];
        _addressController.text = userSnapshot['address'];
        _contactNumberController.text = userSnapshot['contactNumber'];
        _profilePictureUrl = userSnapshot['profilePictureUrl'];
        _userType = userSnapshot['userType'];
        _tripHistory = userSnapshot['tripHistory'];
        _rideCount = userSnapshot['rideCount'];
      });

      if (_userType == 'Driver') {
        setState(() {
          _aggressiveRate = userSnapshot['aggressiveRate'];
          _rating = userSnapshot['rating'];
          _selectedVehicleTypes = userSnapshot['vehicleTypes'].cast<String>();
          _driverLicenseController.text = userSnapshot['driverLicense'];
        });
      }
    }
  }

  void _updateAccountData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (_userType == 'Driver') {
        await FirebaseFirestore.instance.collection('drivers')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'contactNumber': _contactNumberController.text,
          'vehicleInfo': _selectedVehicleTypes,
          'driverLicense': _driverLicenseController.text,
        });
      } else {
        await FirebaseFirestore.instance.collection('passengers')
            .doc(user.uid)
            .update({
          'name': _nameController.text,
          'email': _emailController.text,
          'address': _addressController.text,
          'contactNumber': _contactNumberController.text,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account information updated')),
      );
    }
  }

  Widget _buildTripHistoryTable() {
    if (_tripHistory.isEmpty) {
      return Text('Trip History: None', style: TextStyle(fontSize: 16));
    }

    final limitedTripHistory = _getLimitedTripHistory();
    final columnNames = limitedTripHistory.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Index')),
            for (var columnName in columnNames) DataColumn(
                label: Text(columnName)),
          ],
          rows: limitedTripHistory
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final tripMap = entry.value;

            final cells = [
              DataCell(Text('$index')),
              for (var columnName in columnNames) DataCell(
                  Text(tripMap[columnName].toString())),
            ];

            return DataRow(cells: cells);
          }).toList(),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getLimitedTripHistory() {
    final int endIndex = _startIndex + _rowsPerPage;
    final int tripHistoryLength = _tripHistory.length;

    // Check if endIndex is within the valid range
    if (endIndex > tripHistoryLength) {
      _rowsPerPage = tripHistoryLength -
          _startIndex; // Adjust rowsPerPage to fit within available range
    }

    final List<dynamic> tripHistory = _tripHistory.sublist(
        _startIndex, _startIndex + _rowsPerPage);
    final List<Map<String, dynamic>> limitedTripHistory = tripHistory.cast<
        Map<String, dynamic>>();
    return limitedTripHistory;
  }

  void _showNextRows() {
    setState(() {
      if (_startIndex + 5 < _tripHistory.length) {
        _startIndex += 5;
      }
    });
  }

  void _reverseOrderToggle() {
    setState(() {
      _reverseOrder = !_reverseOrder;
    });
  }


  void _logout(BuildContext context) async {
    try {
      // Sign out the user using Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Navigate to the authentication screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationScreen()),
      );
    } catch (e) {
      // Handle logout error
      print('Logout error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed. Please try again.')),
      );
    }
  }

  Future<void> _selectProfilePictureFromGallery() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final image = File(pickedFile.path);

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${appDir.path}/profile_picture.jpg';

      final compressedImage = await compressImage(image);
      final compressedFile = File(fileName)
        ..writeAsBytesSync(img.encodeJpg(compressedImage));

      setState(() {
        _profilePictureUrl = fileName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture selected')),
      );
    }
  }

  Future<img.Image> compressImage(File image) async {
    final bytes = await image.readAsBytes();
    final img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    final compressedImage = img.copyResize(originalImage, width: 500);

    return compressedImage;
  }

  Future<void> _selectProfilePictureFromCamera() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final image = File(pickedFile.path);

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${appDir.path}/profile_picture.jpg';

      final compressedImage = await compressImage(image);
      final compressedFile = File(fileName)
        ..writeAsBytesSync(img.encodeJpg(compressedImage));

      setState(() {
        _profilePictureUrl = fileName;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture selected')),
      );
    }
  }

  void _deleteProfilePicture() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Delete the current picture from Firebase Storage
      await FirebaseStorage.instance.refFromURL(_profilePictureUrl).delete();

      // Update the profile picture URL in Firestore to an empty string
      await _updateProfilePictureUrl('');

      // Refresh the screen to display the profile picture as empty
      _fetchAccountData();
    }
  }

  Future<void> _updateProfilePictureUrl(String newPictureUrl) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {
            'profilePictureUrl': newPictureUrl,
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account                                  logout'),
        actions: [
          IconButton(
            icon: Tooltip(
              message: 'Logout',
              child: Icon(Icons.logout),
            ),
            onPressed: () {
              _logout(context);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      backgroundColor: Colors.blue[100],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                  ),
                  child: Stack(
                    children: [
                      if (_profilePictureUrl.isNotEmpty)
                        Positioned.fill(
                          child: ClipOval(
                            child: Image.network(
                              _profilePictureUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          // Adjust the top padding as desired
                          child: IconButton(
                            icon: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Select Profile Picture'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Text('Gallery'),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _selectProfilePictureFromGallery();
                                            },
                                          ),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                            child: Text('Camera'),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              _selectProfilePictureFromCamera();
                                            },
                                          ),
                                          if (_profilePictureUrl
                                              .isNotEmpty) ...[
                                            SizedBox(height: 10),
                                            GestureDetector(
                                              child: Text(
                                                  'Delete Current Picture'),
                                              onTap: () {
                                                Navigator.of(context).pop();
                                                _deleteProfilePicture();
                                              },
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('User Type: $_userType', style: TextStyle(fontSize: 16)),
              // Display user type (read-only)
              SizedBox(height: 10,),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _contactNumberController,
                decoration: InputDecoration(labelText: 'Contact Number'),
              ),
              SizedBox(height: 10),
              Text('Ride Count: $_rideCount', style: TextStyle(fontSize: 16)),
              // Display ride count (read-only)
              SizedBox(height: 10),
              // Trip History Table
              Text('Trip History:', style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Container(
                color: Colors.grey[200],
                // Set the desired background color for the table
                child: _buildTripHistoryTable(),
              ),
              Container(
                color: Colors.grey[400], // Set the desired background color
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Next Button
                    ElevatedButton(
                      onPressed: _showNextRows,
                      child: Text('Next'),
                    ),

                    // Reverse Order Button
                    ElevatedButton(
                      onPressed: _reverseOrderToggle,
                      child: Text('Reverse Order'),
                    ),
                  ],
                ),
              ),
              // Display trip history (read-only)
              SizedBox(height: 20),
              if (_userType == 'Driver') ...[
                SizedBox(height: 10),
                Text('Available Vehicle Type:', style: TextStyle(fontSize: 16)),
                _buildVehicleTypeCheckbox('Private Car'),
                _buildVehicleTypeCheckbox('SUV'),
                _buildVehicleTypeCheckbox('Minivan'),
                _buildVehicleTypeCheckbox('Bike'),
                _buildVehicleTypeCheckbox('Bus'),
                _buildVehicleTypeCheckbox('CNG'),
                SizedBox(height: 10),
                TextField(
                  controller: _driverLicenseController,
                  decoration: InputDecoration(labelText: 'Driver License'),
                ),
              ],
              SizedBox(height: 10),
              if (_userType == 'Driver')
                Text(
                  'Aggressive Rate: ${_aggressiveRate ?? "Not available"}',
                  style: TextStyle(fontSize: 16),
                ),
              // Display aggressive rate (read-only)
              SizedBox(height: 10),
              if (_userType == 'Driver')
                Text('Rating: ${_rating ?? "Not available"}',
                    style: TextStyle(fontSize: 16)),
              // Display rating (read-only)

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateAccountData,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeCheckbox(String vehicleType) {
    final bool isSelected = _selectedVehicleTypes.contains(vehicleType);

    return CheckboxListTile(
      title: Text(
        vehicleType,
        style: TextStyle(fontSize: 12), // Adjust the font size as desired
      ),
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value != null && value) {
            _selectedVehicleTypes.add(vehicleType);
          } else {
            _selectedVehicleTypes.remove(vehicleType);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }

}

