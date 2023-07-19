import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:transafe/screens/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController =
  TextEditingController();
  final TextEditingController _driverLicenseController =
  TextEditingController();
  final TextEditingController _emergencyContactController =
  TextEditingController();
  final TextEditingController _nidController = TextEditingController();

  String _userType = ''; // User type: 'Driver' or 'Passenger'
  String _profilePictureUrl = ''; // URL to store the profile picture in Firestore

  void _registerUser(BuildContext context) async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        (_userType == 'Driver' && _selectedVehicleTypes.isEmpty) ||
        (_userType == 'Driver' && _driverLicenseController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    if (_profilePictureUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a profile picture')),
      );
      return;
    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Upload profile picture to Firestore Storage
      if (_profilePictureUrl.isNotEmpty) {
        // Generate a unique filename for the profile picture
        String fileName =
        DateTime.now().millisecondsSinceEpoch.toString();

        // Upload the profile picture to Firestore Storage
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/$fileName');
        UploadTask uploadTask = ref.putFile(File(_profilePictureUrl));
        TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await storageSnapshot.ref.getDownloadURL();

        // Set the download URL as the profile picture URL
        _profilePictureUrl = downloadUrl;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'userType': _userType,
        'emergencyContact':_emergencyContactController.text,
      });

      // Check if user is a driver or passenger
      if (_userType == 'Driver') {
        // Store driver details in another collection
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text,
          'vehicleTypes': _selectedVehicleTypes,
          'driverLicense': _driverLicenseController.text,
          'emergencyContact': _emergencyContactController.text,
          'rating': 0, // Rating set to null initially
          'aggressiveRate': 0, // Aggressive rate set to null initially
          'name': _nameController.text,
          'address': _addressController.text,
          'contactNumber': _contactNumberController.text,
          'profilePictureUrl': _profilePictureUrl,
          'tripHistory': [], // Empty trip history list
          'rideCount': 0, // Initial ride count set to 0
          'available': true,
          'userType': 'Driver',
          'nid': _nidController.text,
        });
      } else {
        // Store passenger details in another collection
        await FirebaseFirestore.instance
            .collection('passengers')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text,
          'address': _addressController.text,
          'name': _nameController.text,
          'contactNumber': _contactNumberController.text,
          'emergencyContact': _emergencyContactController.text,
          'nid': _nidController.text,
          'profilePictureUrl': _profilePictureUrl,
          'tripHistory': [], // Empty trip history list
          'rideCount': 0, // Initial ride count set to 0
          'userType': 'Passenger',
          'lastdriver': 'null',
          'onBoard': false,
        });
      }

      // Navigate to another screen after successful registration
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      // Handle registration error
      print('Registration error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
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

  Future<img.Image> compressImage(File image) async {
    final bytes = await image.readAsBytes();
    final img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    final compressedImage = img.copyResize(originalImage, width: 500);

    return compressedImage;
  }

  List<String> _selectedVehicleTypes = [];

  Widget _buildVehicleTypeCheckbox(String vehicleType) {
    final bool isSelected = _selectedVehicleTypes.contains(vehicleType);

    return CheckboxListTile(
      title: Text(vehicleType),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
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
                          child: Image.file(
                            File(_profilePictureUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    Positioned.fill(
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
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name*'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email*'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password*'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address*'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _contactNumberController,
                decoration: InputDecoration(labelText: 'Contact Number*'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emergencyContactController,
                decoration: InputDecoration(labelText: 'Emergency Contact*'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nidController,
                decoration: InputDecoration(labelText: 'NID*'),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _userType.isNotEmpty ? _userType : null,
                hint: Text('Select user type*'),
                onChanged: (value) {
                  setState(() {
                    _userType = value!;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'Driver',
                    child: Text('Driver'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Passenger',
                    child: Text('Passenger'),
                  ),
                ],
              ),
              if (_userType == 'Driver') ...[
                SizedBox(height: 10),
                TextField(
                  controller: _driverLicenseController,
                  decoration: InputDecoration(labelText: 'Driver License'),
                ),
                SizedBox(height: 10),
                Text('Vehicle Type'),
                _buildVehicleTypeCheckbox('Private Car'),
                _buildVehicleTypeCheckbox('SUV'),
                _buildVehicleTypeCheckbox('Minivan'),
                _buildVehicleTypeCheckbox('Bike'),
                _buildVehicleTypeCheckbox('Bus'),
                _buildVehicleTypeCheckbox('CNG'),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _registerUser(context);
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
