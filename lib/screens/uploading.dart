import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transafe/classes/Pricepaidholder.dart';
import 'package:transafe/screens/screen2.dart';
import 'package:transafe/classes/main_prediction.dart';
import 'package:flutter/cupertino.dart';


class DriverScreen extends StatefulWidget {
  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  List<String> _selectedVehicleTypes = [];
  List<String> _vehicleInfo = ['what'];
  bool _showPreviousElements = false;
  String driverId='';

  @override
  void initState() {
    super.initState();
    _checkAvailability();
    _fetchVehicleInfo();
  }
  void _checkAvailability() async {
    // Get the current user's ID
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }
    driverId = currentUser.uid;

    // Check the 'available' field in the 'drivers' collection
    DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .get();

    Map<String, dynamic>? driverData = driverSnapshot.data() as Map<String, dynamic>?;

    bool isAvailable = driverData?['available'] ?? false;

    setState(() {
      _showPreviousElements = !isAvailable;
    });
  }

  void _fetchVehicleInfo() async {
    // Get the current user's ID
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }
    String driverId = currentUser.uid;

    // Fetch the vehicleInfo from the drivers collection
    DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance.collection('drivers').doc(driverId).get();
    setState(() {
      _vehicleInfo = List<String>.from(driverSnapshot['vehicleTypes']);
      print(_vehicleInfo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ride'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_showPreviousElements)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _sourceController,
                      decoration: InputDecoration(labelText: 'Source'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(labelText: 'Destination'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Select Vehicle Types:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    _buildVehicleTypeChecklist(),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _createRideRecord(context);
                          _showPreviousElements = true;
                        });
                      },
                      child: Text('Create Ride'),
                    ),
                  ],
                ),
                if (_showPreviousElements)
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              // Refresh the data by rebuilding the widget
                            });
                          },
                          child: Text('Refresh Data'),
                        ),
                        SizedBox(height: 16.0),
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

                            return ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: [driverId].map((key) {
                                Map<String, dynamic>? rideMap = ridesMap?[key] as Map<String, dynamic>?;
                                if (rideMap == null) {
                                  return SizedBox.shrink(); // Return an empty widget or handle the null case accordingly
                                }
                                String passenger = rideMap['passengerID'] ?? 'null';
                                String source = rideMap['source'];
                                String destinations = rideMap['destinations'];
                                bool reachedDestination = rideMap['reachedDestination'] ?? false;
                                bool pricePaid = rideMap['pricePaid'] ?? false;
                                bool journeyStarted = rideMap['journeyStarted'] ?? false;
                                bool selected = rideMap['selected'] ?? false;
                                bool accepted = rideMap['accepted'] ?? false;
                                double rating = rideMap['passengerRating'].toDouble();
                                String selectedVehicle = rideMap['selectedVehicle'] ?? 'null';
                                // Extract other fields as needed

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
                                      Text(
                                        'Passenger: $passenger',
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
                                      Row(
                                        children: [
                                          Text(
                                            'Selected: ',
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                          Icon(
                                            selected ? Icons.check_circle : Icons.cancel,
                                            color: selected ? Colors.green : Colors.red,
                                          ),
                                        ],
                                      ),
                                      if (selected)
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
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  // Toggle the accepted value
                                                  accepted = !accepted;
                                                  // Update the value in Firestore
                                                  FirebaseFirestore.instance
                                                      .collection('rides')
                                                      .doc('ESsJfkjGFRASotvFBna1')
                                                      .update({
                                                    'ridesMap.$driverId.accepted': accepted,
                                                  });
                                                });
                                              },
                                              child: Text(
                                                 'Accept',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                   Colors.green,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if(selected && (!reachedDestination))
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
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                // Toggle the journeyStarted value
                                                journeyStarted = true;
                                                // Update the value in Firestore
                                                FirebaseFirestore.instance
                                                    .collection('rides')
                                                    .doc('ESsJfkjGFRASotvFBna1')
                                                    .update({
                                                  'ridesMap.$driverId.journeyStarted': journeyStarted,
                                                });
                                              });

                                              // Navigate to Screen2
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => mainpred(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Start Journey',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(
                                                Colors.green,
                                              ),
                                            ),
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
                                        ],
                                      ),
                                      if (rating != 0)
                                        Row(
                                          children: [
                                            Text(
                                              'Price Paid: ',
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                            Icon(
                                              pricePaid ? Icons.check_circle : Icons.cancel,
                                              color:  Colors.green,
                                            ),
                                            SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  // Update the pricePaid value in the ride document
                                                  await FirebaseFirestore.instance
                                                      .collection('rides')
                                                      .doc('ESsJfkjGFRASotvFBna1')
                                                      .update({
                                                    'ridesMap.$driverId.pricePaid': true,
                                                  });

                                                  print(driverId);
                                                  print(passenger);
                                                  Map<String, dynamic>? driverData;
                                                  Map<String, dynamic>? passengerData;

                                                  // Fetch the driver's document snapshot
                                                  DocumentSnapshot<Map<String, dynamic>> driverSnapshot = await FirebaseFirestore.instance
                                                      .collection('drivers')
                                                      .doc(driverId)
                                                      .get();
                                                  driverData = driverSnapshot.data();
                                                  DocumentSnapshot<Map<String, dynamic>> passengerSnapshot = await FirebaseFirestore.instance
                                                      .collection('passengers')
                                                      .doc(passenger)
                                                      .get();
                                                  passengerData = driverSnapshot.data();

                                                  if (driverData != null && passengerData != null) {
                                                    // Get the driver's current aggressive rate, ride count, and rating
                                                    double aggressiveRate = driverData['aggressiveRate'].toDouble();
                                                    int rideCount = driverData['rideCount'] as int;
                                                    double rating = driverData['rating'].toDouble();

                                                    // Get the driver's aggressive rate and passenger rating from the rideMap
                                                    double driverAggressiveRate = rideMap['driverAggressiveRate'].toDouble();
                                                    double passengerRating = rideMap['passengerRating'].toDouble();
                                                    print(rideMap);

                                                    int passengerridecount = passengerData['rideCount'] as int;
                                                    passengerridecount=passengerridecount+1;
                                                    print(driverAggressiveRate);
                                                    print(passengerRating);
                                                    print(aggressiveRate);
                                                    print(rideCount);
                                                    print(rating);

                                                    // Calculate the new aggressive rate, ride count, and rating
                                                    double newAggressiveRate = ((aggressiveRate * rideCount) + driverAggressiveRate) / (rideCount + 1);
                                                    double newRating = ((rating * rideCount) + passengerRating) / (rideCount + 1);
                                                    int newRideCount = rideCount + 1;
                                                    bool res =true;

                                                    print(newAggressiveRate);
                                                    print(newRideCount);
                                                    print(newRating);

                                                    await FirebaseFirestore.instance.collection('drivers').doc(driverId).update({
                                                      'rating': newRating,
                                                      'rideCount': newRideCount,
                                                      'aggressiveRate': newAggressiveRate,
                                                      'available':res,
                                                    });
                                                    await FirebaseFirestore.instance.collection('passengers').doc(passenger).update({
                                                      'rideCount': passengerridecount,
                                                      'onBoard':false,
                                                    });

                                                    // Update the driver's document with the new aggressive rate, ride count, and rating

                                                    // Adding trip history to passenger and driver
                                                     FirebaseFirestore.instance.collection('passengers').doc(passenger).update({
                                                       'tripHistory': FieldValue.arrayUnion([rideMap]),
                                                     });
                                                     FirebaseFirestore.instance.collection('drivers').doc(driverId).update({
                                                       'tripHistory': FieldValue.arrayUnion([rideMap]),
                                                     });

                                                    // Remove the ride map from the ridesMap field
                                                    FirebaseFirestore.instance
                                                        .collection('rides')
                                                        .doc('ESsJfkjGFRASotvFBna1')
                                                        .update({'ridesMap.$driverId': FieldValue.delete()});

                                                    // Show a success message
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Payment confirmed')),
                                                    );
                                                  } else {
                                                    // Show an error message if driver data is not found
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to fetch driver document')),
                                                    );
                                                  }
                                                } catch (error) {
                                                  // Show an error message if updating the ride document fails
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Failed to update ride document')),
                                                  );
                                                }
                                              },

                                              child: Text(
                                                'Price Paid',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                  Colors.green,
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),
                                      // Display other information
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              SizedBox(height: 16.0),
              if (!_showPreviousElements)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showPreviousElements = true;
                    });
                  },
                  child: Text('Already Created'),
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildVehicleTypeChecklist() {
    return Column(
      children: _vehicleInfo.map((vehicleType) {
        bool isChecked = _selectedVehicleTypes.contains(vehicleType);
        return CheckboxListTile(
          title: Text(vehicleType),
          value: isChecked,
          onChanged: (value) {
            setState(() {
              if (value != null && value) {
                _selectedVehicleTypes.add(vehicleType);
              } else {
                _selectedVehicleTypes.remove(vehicleType);
              }
            });
          },
        );
      }).toList(),
    );
  }
  void _createRideRecord(BuildContext context) async {
    String source = _sourceController.text;
    String destinations = _destinationController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;


    // Get the current user's ID
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
      return;
    }
    String driverId = currentUser.uid;

    try {
      // Get the reference to the existing ride document
      DocumentReference rideRef =
      FirebaseFirestore.instance.collection('rides').doc('ESsJfkjGFRASotvFBna1');

      // Get the driver's document reference
      DocumentReference driverRef =
      FirebaseFirestore.instance.collection('drivers').doc(driverId);

      // Get the driver's data from the document
      DocumentSnapshot driverSnapshot = await driverRef.get();
      print(driverSnapshot.data());


      double aggressiveRate = (driverSnapshot['aggressiveRate'] as num).toDouble();
      int rideCount = driverSnapshot['rideCount'] as int;
      double rating = (driverSnapshot['rating'] as num).toDouble();
      double nid =(driverSnapshot['nid']);


      // Create the new ride map
      Map<String, dynamic> newRide = {
        'driverId': driverId,
        'passengerID': 'null',
        'source': source,
        'destinations': destinations,
        'price': price,
        'reachedDestination': false,
        'pricePaid': false,
        'journeyStarted': false,
        'selected': false,
        'accepted': false,
        'vehicleTypes': _selectedVehicleTypes,
        'selectedVehicle': 'null',
        'tripRating': rating,
        'drivernid':nid,
        'tripAgrresiveRate': aggressiveRate,
        'passengerRating': 0, //take it from the driver account
        'driverAggressiveRate': 0, // take it from the driver account
        'driverTripNumber': rideCount // take it from the driver account
      };

      // Update the 'ridesMap' field in the existing ride document
      await rideRef.update({
        'ridesMap': {driverId: newRide},
      });

      // Update the driver's availability
      await driverRef.update({
        'available': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride created successfully')),
      );
    } catch (e) {
      print('Failed to create ride: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create ride')),
      );
    }
  }


}
