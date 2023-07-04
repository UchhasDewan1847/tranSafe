import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transafe/screens/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _profilePictureController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _picUrlController = TextEditingController();
  final TextEditingController _vehicleInfoController = TextEditingController();
  final TextEditingController _driverLicenseController = TextEditingController();

  String _userType = ''; // User type: 'Driver' or 'Passenger'

  void _registerUser(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Store user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'phoneNumber': _phoneNumberController.text,
        'email': _emailController.text,
        'profilePicture': _profilePictureController.text,
        'userType': _userType,
        'name': _nameController.text,
        'address': _addressController.text,
        'contactNumber': _contactNumberController.text,
        'picUrl': _picUrlController.text,
      });

      // Check if user is a driver or passenger
      if (_userType == 'Driver') {
        // Store driver details in another collection
        await FirebaseFirestore.instance.collection('drivers').doc(userCredential.user!.uid).set({
          'phoneNumber': _phoneNumberController.text,
          'email': _emailController.text,
          'profilePicture': _profilePictureController.text,
          'availability': '',
          'vehicleInfo': _vehicleInfoController.text,
          'driverLicense': _driverLicenseController.text,
          'rating': 0,
          'name': _nameController.text,
          'address': _addressController.text,
          'contactNumber': _contactNumberController.text,
          'picUrl': _picUrlController.text,
        });
      } else {
        // Store passenger details in another collection
        await FirebaseFirestore.instance.collection('passengers').doc(userCredential.user!.uid).set({
          'phoneNumber': _phoneNumberController.text,
          'email': _emailController.text,
          'profilePicture': _profilePictureController.text,
          'address': _addressController.text,
          'name': _nameController.text,
          'contactNumber': _contactNumberController.text,
          'picUrl': _picUrlController.text,
          'userType': 'Passenger',
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
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _profilePictureController,
                decoration: InputDecoration(labelText: 'Profile Picture'),
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
              TextField(
                controller: _picUrlController,
                decoration: InputDecoration(labelText: 'Pic URL'),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: _userType.isNotEmpty ? _userType : null,
                hint: Text('Select user type'),
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
                  controller: _vehicleInfoController,
                  decoration: InputDecoration(labelText: 'Vehicle Info'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _driverLicenseController,
                  decoration: InputDecoration(labelText: 'Driver License'),
                ),
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
