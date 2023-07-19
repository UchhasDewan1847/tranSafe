import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:transafe/screens/loading.dart';
import 'package:transafe/new screens/driververification.dart';
import 'package:transafe/new screens/passengerverification.dart';
import 'package:transafe/new screens/prediction.dart';
import 'package:transafe/new screens/rateus.dart';
import 'package:transafe/new screens/securtiysuggestionscreen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? '';

    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back4.jpeg"), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100.0), // Adjust the bottom padding as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Text(
                    "Welcome to Transafe",
                    style: TextStyle(fontSize: 30, color: Colors.indigo[200]),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'User ID: $userId',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 40),
                  Text(
                    'Home screen',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (currentUser != null) ...[
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return SizedBox();
                        }

                        final userType = snapshot.data?['userType'];

                        return Wrap(
                          spacing: 20, // Adjust the horizontal spacing between the cards
                          runSpacing: 20, // Adjust the vertical spacing between the cards
                          children: [
                            if (true) ...[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PassengerVerificationScreen()),
                                  );
                                },
                                child: buildNavigationCard(
                                  title: 'Passenger Verification',
                                  icon: Icons.person,
                                  color: Colors.lightGreen,
                                ),
                              ),
                            ],
                            if (userType != 'Driver') ...[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => DriverVerificationScreen()),
                                  );
                                },
                                child: buildNavigationCard(
                                  title: 'Driver Verification',
                                  icon: Icons.directions_car,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RateApplicationScreen()),
                                );
                              },
                              child: buildNavigationCard(
                                title: 'Rate the Application',
                                icon: Icons.star,
                                color: Colors.orangeAccent,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SecuritySuggestionsScreen()),
                                );
                              },
                              child: buildNavigationCard(
                                title: 'Get Suggestions on Security and Safety',
                                icon: Icons.security,
                                color: Colors.purpleAccent,
                              ),
                            ),
                            if (userType != 'Driver') ...[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SuspicionScreen()),
                                  );
                                },
                                child: buildNavigationCard(
                                  title: 'Feeling Suspicious?',
                                  icon: Icons.warning,
                                  color: Colors.deepOrangeAccent,
                                ),
                              ),
                            ],
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => WeatherScreen()),
                                );
                              },
                              child: buildNavigationCard(
                                title: 'Weather',
                                icon: Icons.cloud,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }






  Widget buildNavigationCard({required String title, required IconData icon, required Color color}) {
    return Container(
      width: 250, // Adjust the width as needed
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, dynamic> weatherData = {};

  @override
  void initState() {
    super.initState();
    fetchWeatherData().then((data) {
      setState(() {
        weatherData = data;
      });
    });
  }

  Future<Map<String, dynamic>> fetchWeatherData() async {
    final apiKey = '9aadcca125ce5f4958189b8ed439da5b';
    final city = 'Dhaka'; // Replace with the desired city name

    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    double temperature = weatherData['main']['temp'];
    double celsius = temperature - 273.15;
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/weather.png"), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: weatherData.isEmpty
              ? CircularProgressIndicator()
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Temperature: ${celsius.toStringAsFixed(1)}°C',
              ),
              Text(
                'Description: ${weatherData['weather'][0]['description']}',
              ),
              Text(
                'Humidity: ${weatherData['main']['humidity']}%',
              ),
              Text(
                'Wind Speed: ${weatherData['wind']['speed']} m/s',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
