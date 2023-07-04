import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transafe/screens/authentication_screen.dart';
import 'package:transafe/screens/home_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not logged in, show the authentication screen
      return AuthenticationScreen();
    } else {
      // User is logged in, show the home screen
      return HomeScreen();
    }
  }
}
