import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SecuritySuggestionsScreen extends StatelessWidget {
  final List<String> websites = [
    'https://drifttravel.com/safety-tips-when-traveling-using-public-transport/',
    'https://www.springfieldmo.gov/307/Public-Transportation-Safety-Tips',
    'https://www.penndot.pa.gov/TravelInPA/PublicTransitOptions/Pages/Safety-and-Etiquette-Tips.aspx',
  ];

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suggestions on Security'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/safetysuggestion.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riding public transit is an affordable and sustainable way to go. But as you ride, safety should always be top of mind. Make sure you\'re alert by following these tips:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  height: 2.0,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                ),
                Text(
                  '1. Know Where You\'re Going',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Have your route planned out ahead of time so you can pay more attention to your surroundings. The Transit app (link is external) provides real-time data for all transit agencies serving UCLA, and the Tripshot app (link is external) provides real-time tracking for BruinBus.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                Text(
                  '2. Have Your Fare Ready',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Have your exact fare or TAP card ready before you board so you aren\'t fumbling with your wallet or purse and risk exposing your money.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                Text(
                  '3. Stay Away from Curbs and Edges',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'Make sure you\'re on the sidewalk and away from the curb while waiting for a bus or standing away from the edge of the platform when waiting for a train.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                Text(
                  '4. Keep Belongings Close to You',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'If you\'re carrying bags, make sure they\'re on your lap or between your feet and not on an empty seat beside you. Put your phone away when getting off and on as that\'s when it\'s most likely to get stolen.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                Text(
                  '5. Don\'t Sit Near Exits',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '"Snatch and grabs" are most likely to occur near the exit doors. The best places to sit are near the driver or the aisle.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                Text(
                  '6. Stay Alert at All Times',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  'While you may be on your phone or reading a book while riding, make sure you look up from time to time so you\'re aware of your surroundings and don\'t become an easy target.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 16.0),
                Text(
                  'For more information, visit the following websites:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                SizedBox(height: 8.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: websites.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _launchUrl(websites[index]),
                      child: Text(
                        websites[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
