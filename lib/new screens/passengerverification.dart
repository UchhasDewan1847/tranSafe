import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PassengerVerificationScreen extends StatefulWidget {
  @override
  _PassengerVerificationScreenState createState() =>
      _PassengerVerificationScreenState();
}

class _PassengerVerificationScreenState
    extends State<PassengerVerificationScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isVerified = false;
  List<String>? _verifiedPassengersList;

  @override
  void initState() {
    super.initState();
    _fetchVerifiedPassengersList();
  }

  Future<void> _fetchVerifiedPassengersList() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('verifiedpassengers')
        .doc('bblSE7Am2mIspCy1X9UW')
        .get();

    final data = snapshot.data();
    if (data != null && data.containsKey('passengers')) {
      _verifiedPassengersList = List<String>.from(data['passengers']);
      print("Verified Passengers List: $_verifiedPassengersList");
    } else {
      print("Verified Passengers List is null or list field is missing");
    }
  }

  Future<bool> _checkVerification(String input) async {
    if (_verifiedPassengersList == null) {
      return false;
    }

    final cleanInput = input.trim();

    for (var element in _verifiedPassengersList!) {
      if (element == cleanInput) {
        return true;
      }
    }
    return false;
  }

  void _submitVerification() async {
    final input = _inputController.text.trim();
    print(input);

    if (input.isNotEmpty) {
      final isVerified = await _checkVerification(input.toString());
      print('isVerified is ' + isVerified.toString());

      setState(() {
        _isVerified = isVerified;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Passenger Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Passenger Verification',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  labelText: 'Enter Passenger ID',
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _submitVerification(),
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
                    'Passenger Verified!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            if (!_isVerified)
              Text(
                'Not Verified',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
