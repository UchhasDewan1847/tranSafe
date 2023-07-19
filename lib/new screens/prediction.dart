import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sklite/SVM/SVM.dart';
import 'package:sklite/utils/io.dart';

class SuspicionScreen extends StatefulWidget {
  @override
  _SuspicionScreenState createState() => _SuspicionScreenState();
}

class _SuspicionScreenState extends State<SuspicionScreen> {
  LinearSVC? lnsvc;
  List<int?> inputData = [];
  bool predicted=false;
  String? _prediction;
  int? isDriverKnown;
  int? isDriverVerified;
  int? isPassengerBehaviorGood;
  int? qualityOfDriving;
  int? isDriverTakingAlternativeRoute;
  int? isDriverMakingUnplannedStops;
  int? isDriverTalkingToFrequentMobile;
  int? isRouteKnownToPassenger;
  int? isIncidentOccurred;
  int? passengerGender;
  int? passengerBaggageType;
  int? isPassengerPressurized;
  int? isPassengerTeased;
  int? isRouteProneToDangerousActivity;
  int? isDriverMakingRideLong;
  int? isDriverLookingThroughMirrorFrequently;
  int? roadQuality;
  int? isCoordinatedActivity;
  int? vehicleCondition;
  int? driverBehavior;
  int? didDriverFollowTrafficRules;
  int? didDriverAskInappropriateQuestion;
  int? isDriverTakingDetours;
  int? isDriverMakingPassengerUneasy;

  void initState() {
    super.initState();
    loadModel("assets/linearsvc.json").then((x) {
      setState(() {
        lnsvc = LinearSVC.fromMap(json.decode(x));
      });
    });
  }

  void handleSubmit() {
    if (isDriverKnown == null ||
        isDriverVerified == null ||
        isPassengerBehaviorGood == null ||
        qualityOfDriving == null ||
        isDriverTakingAlternativeRoute == null ||
        isDriverMakingUnplannedStops == null ||
        isDriverTalkingToFrequentMobile == null ||
        isRouteKnownToPassenger == null ||
        isIncidentOccurred == null ||
        passengerGender == null ||
        passengerBaggageType == null ||
        isPassengerPressurized == null ||
        isPassengerTeased == null ||
        isRouteProneToDangerousActivity == null ||
        isDriverMakingRideLong == null ||
        isDriverLookingThroughMirrorFrequently == null ||
        roadQuality == null ||
        isCoordinatedActivity == null ||
        vehicleCondition == null ||
        driverBehavior == null ||
        didDriverFollowTrafficRules == null ||
        didDriverAskInappropriateQuestion == null ||
        isDriverTakingDetours == null ||
        isDriverMakingPassengerUneasy == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Missing Answers'),
          content: Text('Please answer all the questions.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    inputData = [
      isDriverKnown,
      isDriverVerified,
      isPassengerBehaviorGood,
      qualityOfDriving,
      isDriverTakingAlternativeRoute,
      isDriverMakingUnplannedStops,
      isDriverTalkingToFrequentMobile,
      isRouteKnownToPassenger,
      isIncidentOccurred,
      passengerGender,
      passengerBaggageType,
      isPassengerPressurized,
      isPassengerTeased,
      isRouteProneToDangerousActivity,
      isDriverMakingRideLong,
      isDriverLookingThroughMirrorFrequently,
      roadQuality,
      isCoordinatedActivity,
      vehicleCondition,
      driverBehavior,
      didDriverFollowTrafficRules,
      didDriverAskInappropriateQuestion,
      isDriverTakingDetours,
      isDriverMakingPassengerUneasy,
    ];
    makePrediction();
    predicted=true;

    // Print the inputData list (for demonstration purposes)
    print(inputData);
  }

  void makePrediction() {
    if (lnsvc != null) {
      List<double> proinput = inputData.map((e) => e!.toDouble()).toList();
      int prediction = lnsvc!.predict(proinput).toInt();
      setState(() {
        if (prediction == 1)
          _prediction = ' Suspicious Activity Detected! ';
        else if (prediction == 2)
          _prediction = 'Safe';
      });
    } else {
      setState(() {
        _prediction = 'Error: Model not loaded';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feeling Suspicious?'),
      ),
      body: ListView(
          scrollDirection: Axis.horizontal,
        children: [
          SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/question.jpg"), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16.0),
                  if (!predicted) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Please fill up the following questions',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigoAccent[200]),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20,),
                        Text('Is the Driver known to you?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverKnown,
                              onChanged: (value) {
                                setState(() {
                                  isDriverKnown = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverKnown,
                              onChanged: (value) {
                                setState(() {
                                  isDriverKnown = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Is the Driver verified?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverVerified,
                              onChanged: (value) {
                                setState(() {
                                  isDriverVerified = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverVerified,
                              onChanged: (value) {
                                setState(() {
                                  isDriverVerified = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('How are other Passengers behavior?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Unsusual', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isPassengerBehaviorGood,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerBehaviorGood = value;
                                });
                              },
                            ),
                            Text('Normal', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isPassengerBehaviorGood,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerBehaviorGood = value;
                                });
                              },
                            ),
                            Text('Fearful', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 3,
                              groupValue: isPassengerBehaviorGood,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerBehaviorGood = value;
                                });
                              },
                            ),
                            Text('You are alone', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 4,
                              groupValue: isPassengerBehaviorGood,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerBehaviorGood = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Quality of the driving?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Agressive', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: qualityOfDriving,
                              onChanged: (value) {
                                setState(() {
                                  qualityOfDriving = value;
                                });
                              },
                            ),
                            Text('Slow', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: qualityOfDriving,
                              onChanged: (value) {
                                setState(() {
                                  qualityOfDriving = value;
                                });
                              },
                            ),
                            Text('Normal', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 3,
                              groupValue: qualityOfDriving,
                              onChanged: (value) {
                                setState(() {
                                  qualityOfDriving = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Driver taking alternative route?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverTakingAlternativeRoute,
                              onChanged: (value) {
                                setState(() {
                                  isDriverTakingAlternativeRoute = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverTakingAlternativeRoute,
                              onChanged: (value) {
                                setState(() {
                                  isDriverTakingAlternativeRoute = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Driver making unplanned stops?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverMakingUnplannedStops,
                              onChanged: (value) {
                                setState(() {
                                  isDriverMakingUnplannedStops = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverMakingUnplannedStops,
                              onChanged: (value) {
                                setState(() {
                                  isDriverMakingUnplannedStops = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Driver talking to mobile frequently?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverTalkingToFrequentMobile,
                              onChanged: (value) {
                                setState(() {
                                  isDriverTalkingToFrequentMobile = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverTalkingToFrequentMobile,
                              onChanged: (value) {
                                setState(() {
                                  isDriverTalkingToFrequentMobile = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Route is known to the passenger?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isRouteKnownToPassenger,
                              onChanged: (value) {
                                setState(() {
                                  isRouteKnownToPassenger = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isRouteKnownToPassenger,
                              onChanged: (value) {
                                setState(() {
                                  isRouteKnownToPassenger = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Occurrences of any incident?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isIncidentOccurred,
                              onChanged: (value) {
                                setState(() {
                                  isIncidentOccurred = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isIncidentOccurred,
                              onChanged: (value) {
                                setState(() {
                                  isIncidentOccurred = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('What is your gender?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Male', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: passengerGender,
                              onChanged: (value) {
                                setState(() {
                                  passengerGender = value;
                                });
                              },
                            ),
                            Text('Female', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: passengerGender,
                              onChanged: (value) {
                                setState(() {
                                  passengerGender = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('What kind of baggage is the passenger taking?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('None', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: passengerBaggageType,
                              onChanged: (value) {
                                setState(() {
                                  passengerBaggageType = value;
                                });
                              },
                            ),
                            Text('Valuable', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: passengerBaggageType,
                              onChanged: (value) {
                                setState(() {
                                  passengerBaggageType = value;
                                });
                              },
                            ),
                            Text('Not Valuable', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 3,
                              groupValue: passengerBaggageType,
                              onChanged: (value) {
                                setState(() {
                                  passengerBaggageType = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Was the passenger pressurised to do something?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isPassengerPressurized,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerPressurized = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isPassengerPressurized,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerPressurized = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Passenger teased?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isPassengerTeased,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerTeased = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isPassengerTeased,
                              onChanged: (value) {
                                setState(() {
                                  isPassengerTeased = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Route prone to dangerous activity?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isRouteProneToDangerousActivity,
                              onChanged: (value) {
                                setState(() {
                                  isRouteProneToDangerousActivity = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isRouteProneToDangerousActivity,
                              onChanged: (value) {
                                setState(() {
                                  isRouteProneToDangerousActivity = value;
                                });
                              },
                            ),
                            Text('Not Sure', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 3,
                              groupValue: isRouteProneToDangerousActivity,
                              onChanged: (value) {
                                setState(() {
                                  isRouteProneToDangerousActivity = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Driver making the ride deliberately long?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverMakingRideLong,
                              onChanged: (value) {
                                setState(() {
                                  isDriverMakingRideLong = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverMakingRideLong,
                              onChanged: (value) {
                                setState(() {
                                  isDriverMakingRideLong = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Driver looking through mirror frequently?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverLookingThroughMirrorFrequently,
                              onChanged: (value) {
                                setState(() {
                                  isDriverLookingThroughMirrorFrequently = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverLookingThroughMirrorFrequently,
                              onChanged: (value) {
                                setState(() {
                                  isDriverLookingThroughMirrorFrequently = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Road quality?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Good', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: roadQuality,
                              onChanged: (value) {
                                setState(() {
                                  roadQuality = value;
                                });
                              },
                            ),
                            Text('Bad', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: roadQuality,
                              onChanged: (value) {
                                setState(() {
                                  roadQuality = value;
                                });
                              },
                            ),
                            Text('Dangerous', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 3,
                              groupValue: roadQuality,
                              onChanged: (value) {
                                setState(() {
                                  roadQuality = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Any coordinated activity?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isCoordinatedActivity,
                              onChanged: (value) {
                                setState(() {
                                  isCoordinatedActivity = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isCoordinatedActivity,
                              onChanged: (value) {
                                setState(() {
                                  isCoordinatedActivity = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Vehicle condition?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Good', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: vehicleCondition,
                              onChanged: (value) {
                                setState(() {
                                  vehicleCondition = value;
                                });
                              },
                            ),
                            Text('Old', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: vehicleCondition,
                              onChanged: (value) {
                                setState(() {
                                  vehicleCondition = value;
                                });
                              },
                            ),
                            Text('Needs Fixing', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 3,
                              groupValue: vehicleCondition,
                              onChanged: (value) {
                                setState(() {
                                  vehicleCondition = value;
                                });
                              },
                            ),

                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('How was the driver’s behavior?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Good', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: driverBehavior,
                              onChanged: (value) {
                                setState(() {
                                  driverBehavior = value;
                                });
                              },
                            ),
                            Text('Agressive', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: driverBehavior,
                              onChanged: (value) {
                                setState(() {
                                  driverBehavior = value;
                                });
                              },
                            ),
                            Text('Unusual', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 3,
                              groupValue: driverBehavior,
                              onChanged: (value) {
                                setState(() {
                                  driverBehavior = value;
                                });
                              },
                            ),
                            Text('Reckless', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 4,
                              groupValue: driverBehavior,
                              onChanged: (value) {
                                setState(() {
                                  driverBehavior = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Did the driver follow traffic rules?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: didDriverFollowTrafficRules,
                              onChanged: (value) {
                                setState(() {
                                  didDriverFollowTrafficRules = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: didDriverFollowTrafficRules,
                              onChanged: (value) {
                                setState(() {
                                  didDriverFollowTrafficRules = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Driver asked any inappropriate or personal question?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: didDriverAskInappropriateQuestion,
                              onChanged: (value) {
                                setState(() {
                                  didDriverAskInappropriateQuestion = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: didDriverAskInappropriateQuestion,
                              onChanged: (value) {
                                setState(() {
                                  didDriverAskInappropriateQuestion = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Is the driver taking detours?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverTakingDetours,
                              onChanged: (value) {
                                setState(() {
                                  isDriverTakingDetours = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverTakingDetours,
                              onChanged: (value) {
                                setState(() {
                                  isDriverTakingDetours = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Driver made uneasy or threatening environment?', style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Yes', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 1,
                              groupValue: isDriverMakingPassengerUneasy,
                              onChanged: (value) {
                                setState(() {
                                  isDriverMakingPassengerUneasy = value;
                                });
                              },
                            ),
                            Text('No', style: TextStyle(color: Colors.indigo[100],fontSize: 12)),
                            Radio(
                              value: 2,
                              groupValue: isDriverMakingPassengerUneasy,
                              onChanged: (value) {
                                setState(() {
                                  isDriverMakingPassengerUneasy = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: handleSubmit,
                      child: Text('Submit'),
                    ),
                  ],
                  if (predicted)
                    SingleChildScrollView(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _prediction!,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.0),
                            SizedBox(height: 8.0),
                            SizedBox(height: 16.0),
                            Text(
                              'Please follow these steps:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              width: 300, // Adjust the width as needed
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Text(
                                      '1. Call Emergency 999/100',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '2. Provide your name and location',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '3. Describe what you see',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '4. Provide a description of the person(s) involved',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '5. Share the location of the person(s) involved using the Map Screen and "send location" button',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '6. Keep a safe distance from the person until law enforcement arrives',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '7. If it is safe, observe and note important details like height, weight, sex, complexion, approximate age, clothing, method and direction of travel, and name if known',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(
                                      '8. If the person attempts to leave in a vehicle, make note of the vehicle\'s make, model, license number, color, and any outstanding characteristics',
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: 16.0),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        predicted = false;
                                        isDriverKnown = 0;
                                        isDriverVerified = 0;
                                        isPassengerBehaviorGood = 0;
                                        qualityOfDriving = 0;
                                        isDriverTakingAlternativeRoute = 0;
                                        isDriverMakingUnplannedStops = 0;
                                        isDriverTalkingToFrequentMobile = 0;
                                        isRouteKnownToPassenger = 0;
                                        isIncidentOccurred = 0;
                                        passengerGender = 0;
                                        passengerBaggageType = 0;
                                        isPassengerPressurized = 0;
                                        isPassengerTeased = 0;
                                        isRouteProneToDangerousActivity = 0;
                                        isDriverMakingRideLong = 0;
                                        isDriverLookingThroughMirrorFrequently = 0;
                                        roadQuality = 0;
                                        isCoordinatedActivity = 0;
                                        vehicleCondition = 0;
                                        driverBehavior = 0;
                                        didDriverFollowTrafficRules = 0;
                                        didDriverAskInappropriateQuestion = 0;
                                        isDriverTakingDetours = 0;
                                        isDriverMakingPassengerUneasy = 0;
                                      });
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        ]
      ),
    );
  }

}
