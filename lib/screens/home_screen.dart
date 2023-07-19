import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transafe/screens/authentication_screen.dart';
import 'package:transafe/screens/screen3.dart';
import 'package:transafe/screens/screen4.dart';
import 'package:transafe/screens/screen1.dart';
import 'package:transafe/screens/screen2.dart';
import 'package:transafe/screens/uploading.dart';
import 'package:transafe/screens/booking.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _fetchAccountData();
  }

  Future<void> _fetchAccountData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String userType = userSnapshot['userType'];

      setState(() {
        // Update _screens list based on userType
        if (userType == 'Driver') {
          _screens = [
            Screen1(),
            DriverScreen(),
            Screen2(),
            Screen3(),
            AccountScreen(),
          ];
        } else if (userType == 'Passenger') {
          _screens = [
            Screen1(),
            Booking(),
            Screen2(),
            Screen3(),
            AccountScreen(),
          ];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Have a Safe Trip'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.indigo,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.card_travel),
            label: 'Uploading Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            backgroundColor: Colors.blue,
            label: 'Journey',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.emergency_share),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.person),
            label: 'Account Settings',
          ),
        ],
      ),
    );
  }
}


