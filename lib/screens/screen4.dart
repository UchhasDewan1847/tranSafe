import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transafe/screens/authentication_screen.dart';
import 'dart:ui' as ui;

class Screen4 extends StatefulWidget {
  @override
  _Screen4State createState() => _Screen4State();
}

class _Screen4State extends State<Screen4> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the profile information from Firestore and populate the text controllers
    fetchProfileInformation();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void fetchProfileInformation() async {
    // TODO: Implement fetching profile information from Firestore
    // Replace the following lines with your own Firestore query to retrieve the profile information

    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        _firstNameController.text = data['firstName'] ?? '';
        _lastNameController.text = data['lastName'] ?? '';
        _emailController.text = data['email'] ?? '';
      });
    }
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

  void _saveChanges() {
    // TODO: Implement saving changes functionality
    // Get the updated values from the text controllers and update the profile information
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;

    // Perform the necessary update operations

    // Show a success message or perform any other required actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Changes saved successfully!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/back4.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Account'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Editable profile information
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                SizedBox(height: 20),
                // Save button
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: Text('Save Changes'),
                ),
                SizedBox(height: 20),
                // Logout button
                ElevatedButton(
                  onPressed: () {
                    _logout(context);
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}