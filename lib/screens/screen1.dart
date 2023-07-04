import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:transafe/screens/loading.dart';

class Screen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back4.jpeg"), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text(
            'Home screen',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WeatherScreen()),
                  );
                },
                child: Text('Show Weather'),
              ),
            ],
          ),
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
