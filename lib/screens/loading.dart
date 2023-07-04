import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the desired background color
      body: Center(
        child: CircularProgressIndicator(), // Use your preferred loading indicator widget
      ),
    );
  }
}
