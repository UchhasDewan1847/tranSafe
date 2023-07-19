import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

enum SortBy {
  Price,
  AggressiveRate,
  Rating,
  TripNumber,
}

class Booking extends StatefulWidget {
  const Booking({Key? key}) : super(key: key);

  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? _selectedVehicle;
  String key_value='';
  String source = '';
  String destination = '';
  List<Map<String, dynamic>> _ridesData = [];
  SortBy _sortBy = SortBy.Price;
  bool isOnBoard = false;
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _fetchOnBoardStatus();
  }

  Future<void> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  Future<void> _fetchOnBoardStatus() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
      await FirebaseFirestore.instance.collection('passengers').doc(currentUserId).get();

      final Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

      if (userData != null) {
        setState(() {
          isOnBoard = userData['onBoard'] ?? false;
          key_value = userData['lastdriver'];
        });
      }
    } catch (e) {
      print('Error fetching onBoard status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(!isOnBoard)
            Container(
            padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "Enter the source and destination to see available trips",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          source = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Source',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          destination = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Destination',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _fetchRidesData();
              },
              child: Text('Fetch Rides'),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sort By:'),
                SizedBox(width: 8.0),
                DropdownButton<SortBy>(
                  value: _sortBy,
                  onChanged: (SortBy? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _sortBy = newValue;
                        _sortRides();
                      });
                    }
                  },
                  items: SortBy.values.map<DropdownMenuItem<SortBy>>(
                        (SortBy sortBy) {
                      return DropdownMenuItem<SortBy>(
                        value: sortBy,
                        child: Text(sortBy.toString().split('.').last),
                      );
                    },
                  ).toList(),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Column(
              children: _ridesData.map((rideData) => Container(
                width: double.infinity,
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'from   ' + rideData['source'],
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),
                              ),
                              Text(
                                'to     ' + rideData['destinations'],
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,fontStyle: FontStyle.italic),
                              ),
                              SizedBox(height: 10.0,),
                              Text(
                                'Price: ${rideData['price']}',
                                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10.0,),
                              Text(
                                'Driver Trip Number: ${rideData['driverTripNumber']}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Text(
                                'Trip Aggressive Rate: ${rideData['tripAgrresiveRate']}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              Text(
                                'Trip Rating: ${rideData['tripRating']}',
                                style: TextStyle(fontSize: 14.0),
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  key_value = rideData['driverId'];
                                  print(key_value);
                                  FirebaseFirestore.instance.collection('passengers').doc(currentUserId).update({'onBoard': true});
                                  FirebaseFirestore.instance.collection('passengers').doc(currentUserId).update({'lastdriver': key_value});
                                  FirebaseFirestore.instance.collection('rides').doc('ESsJfkjGFRASotvFBna1')..update({'ridesMap.$key_value.passengerID':currentUserId});
                                  FirebaseFirestore.instance.collection('rides').doc('ESsJfkjGFRASotvFBna1')..update({'ridesMap.$key_value.selected':true});
                                  FirebaseFirestore.instance.collection('rides').doc('ESsJfkjGFRASotvFBna1')..update({'ridesMap.$key_value.selectedVehicle':_selectedVehicle});
                                },
                                child: Text(
                                  'Select Ride',
                                  style: TextStyle(color: Colors.white, backgroundColor: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: (rideData['vehicleTypes'] as List<dynamic>)?.map((type) {
                              final String vehicleType = type.toString();
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: RadioListTile<String>(
                                  title: Text(vehicleType),
                                  value: vehicleType,
                                  groupValue: _selectedVehicle,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedVehicle = value!;
                                    });
                                  },
                                  dense: true,
                                ),
                              );
                            }).toList() ?? [Text('No vehicle types available')],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )).toList(),
            ),

          ],
        ),
      ), SizedBox(height: 16.0),
              if(isOnBoard)
                Column(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rides')
                          .doc('ESsJfkjGFRASotvFBna1')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (!snapshot.hasData) {
                          return Text('No data found');
                        }

                        // Access the 'ridesMap' field
                        Map<String, dynamic>? ridesMap =
                        snapshot.data?['ridesMap'] as Map<String, dynamic>?;

                        if (ridesMap == null) {
                          return Text('No ride data found');
                        }

                        // Extract the desired ride from the 'ridesMap'
                        Map<String, dynamic>? selectedRideMap =
                        ridesMap[key_value] as Map<String, dynamic>?;

                        if (selectedRideMap == null) {
                          return Text('Selected ride not found');
                        }

                        String driver = selectedRideMap['driverId'] ?? 'null';
                        String source = selectedRideMap['source'];
                        String destinations = selectedRideMap['destinations'];
                        bool reachedDestination = selectedRideMap['reachedDestination'] ?? false;
                        bool pricePaid = selectedRideMap['pricePaid'] ?? false;
                        bool journeyStarted = selectedRideMap['journeyStarted'] ?? false;
                        double price = selectedRideMap['price'].toDouble();
                        bool accepted = selectedRideMap['accepted'] ?? false;
                        double rating = selectedRideMap['tripRating'].toDouble();
                        String selectedVehicle = selectedRideMap['selectedVehicle'] ?? 'null';

                        return Container(
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Accepted: ',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  Icon(
                                    accepted ? Icons.check_circle : Icons.cancel,
                                    color: accepted ? Colors.green : Colors.red,
                                  ),
                                ],
                              ),
                              Text(
                                'Driver ID: $driver',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Text(
                                'Driver account rating: $rating',
                                style: TextStyle(fontSize: 22.0),
                              ),
                              Text(
                                'Source: $source',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Text(
                                'Destinations: $destinations',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Text(
                                'Selected Vehicle: $selectedVehicle',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Text(
                                'Price: $price',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Journey Started: ',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  Icon(
                                    journeyStarted ? Icons.check_circle : Icons.cancel,
                                    color: journeyStarted ? Colors.green : Colors.red,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Reached Destination: ',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  Icon(
                                    reachedDestination ? Icons.check_circle : Icons.cancel,
                                    color: reachedDestination ? Colors.green : Colors.red,
                                  ),
                                  Visibility(
                                    visible: journeyStarted, // Show the button only when journeyStarted is true
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Update the value of 'reachedDestination' to true in Firestore
                                        FirebaseFirestore.instance
                                            .collection('rides')
                                            .doc('ESsJfkjGFRASotvFBna1')
                                            .update({'ridesMap.$key_value.reachedDestination': true});
                                      },
                                      child: Text('Mark as Reached'),
                                    ),
                                  ),
                                ],
                              ),



                              Row(
                                children: [
                                  Text(
                                    'Price Paid: ',
                                    style: TextStyle(fontSize: 18.0),
                                  ),
                                  Icon(
                                    pricePaid ? Icons.check_circle : Icons.cancel,
                                    color: pricePaid ? Colors.green : Colors.red,
                                  ),
                                ],
                              ),
                              if (reachedDestination) // Show the rating section when pricePaid is true
                                Column(
                                  children: [
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Rating:',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    RatingBar.builder(
                                      initialRating: rating, // Use the initial rating value
                                      minRating: 0.5,
                                      maxRating: 10.0,
                                      itemSize: 30.0,
                                      itemBuilder: (context, index) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (newRating) {
                                        // Update the rating value
                                        double updatedRating = newRating * 2; // Scale the rating to the desired range
                                        FirebaseFirestore.instance
                                            .collection('rides')
                                            .doc('ESsJfkjGFRASotvFBna1')
                                            .update({'ridesMap.$key_value.passengerRating': updatedRating});
                                      },
                                    ),
                                    SizedBox(height: 16.0),
                                    Text(
                                      'Write a Review:',
                                      style: TextStyle(fontSize: 18.0),
                                    ),
                                    TextField(
                                      onChanged: (text) {
                                        // Store the review text
                                        FirebaseFirestore.instance
                                            .collection('rides')
                                            .doc('ESsJfkjGFRASotvFBna1')
                                            .update({'ridesMap.$key_value.passengerReview': text});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Enter your review',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Visibility(
                                      visible: selectedRideMap['passengerRating'] != 0,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Save the map in the "passengers" collection and update the fields
                                          FirebaseFirestore.instance
                                              .collection('passengers')
                                              .doc(currentUserId)
                                              .update({
                                            'onBoard': false,
                                          });
                                        },
                                        child: Text('Exit'),
                                      ),
                                    ),
                                  ],
                                ),

                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )

            ]
           ),
        ),
      ),
    );
  }
  Future<void> _fetchRidesData() async {
    try {
      print('Source: $source');
      print('Destination: $destination');

      final DocumentSnapshot<Map<String, dynamic>> ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .doc('ESsJfkjGFRASotvFBna1') // Replace with your document ID
          .get();

      final Map<String, dynamic>? ridesData = ridesSnapshot.data() as Map<String, dynamic>?;

      if (ridesData != null) {
        final Map<String, dynamic> ridesMap = ridesData['ridesMap'] as Map<String, dynamic>;
        final List<Map<String, dynamic>> allRidesList = ridesMap.entries
            .map((entry) => entry.value as Map<String, dynamic>)
            .toList();

        final List<Map<String, dynamic>> matchedRidesList = allRidesList
            .where((rideMap) {
          final rideSource = rideMap['source'];
          final rideDestination = rideMap['destinations'];
          print('Checking Ride: Source: $rideSource, Destination: $rideDestination');
          return rideSource == source && rideDestination == destination;
        })
            .toList();

        setState(() {
          _ridesData = matchedRidesList;
        });

        _sortRides();

        print('Total Rides Fetched: ${allRidesList.length}');
        print('Total Rides Matched: ${matchedRidesList.length}');
      }
    } catch (e) {
      print('Error fetching rides data: $e');
      // Handle the error as needed
      if (e is FirebaseException && e.code == 'permission-denied') {
        print('Permission Denied: You do not have permission to access rides data.');
      }
    }
  }

  void _sortRides() {
    switch (_sortBy) {
      case SortBy.Price:
        _ridesData.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case SortBy.AggressiveRate:
        _ridesData.sort((a, b) => (a['tripAgrresiveRate'] as double).compareTo(b['tripAgrresiveRate'] as double));
        break;
      case SortBy.Rating:
        _ridesData.sort((a, b) => (b['tripRating'] as double).compareTo(a['tripRating'] as double));
        break;
      case SortBy.TripNumber:
        _ridesData.sort((a, b) => (b['driverTripNumber'] as int).compareTo(a['driverTripNumber'] as int));
        break;
    }
  }
}
