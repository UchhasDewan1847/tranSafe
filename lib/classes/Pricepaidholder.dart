import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PricePaidHandler {
  static Future<void> handlePricePaid(BuildContext context, bool pricePaid, String driverId, Map<String, dynamic> rideMap,String passengerId) async {
    // Toggle the pricePaid value
    pricePaid = !pricePaid;

    try {
      // Update the pricePaid value in the ride document
      await FirebaseFirestore.instance.collection('rides').doc('ESsJfkjGFRASotvFBna1').update({
        'ridesMap.$driverId.pricePaid': pricePaid,
      });

      if (pricePaid) {
        // Get the driver's document reference
        DocumentReference driverRef = FirebaseFirestore.instance.collection('drivers').doc(driverId);

        // Fetch the driver's document snapshot
        DocumentSnapshot driverSnapshot = await driverRef.get();

        // Get the driver's data from the snapshot
        Map<String, dynamic>? driverData = driverSnapshot.data() as Map<String, dynamic>?;

        if (driverData != null) {
          // Get the driver's current aggressive rate, ride count, and rating
          double aggressiveRate = driverData['aggressiveRate'] ?? 0.0;
          int rideCount = driverData['rideCount'] ?? 0;
          double rating = driverData['rating'] ?? 0.0;

          // Get the driver's aggressive rate and passenger rating from the rideMap
          double driverAggressiveRate = rideMap['driverAggressiveRate'] ?? 0.0;
          double passengerRating = rideMap['passengerRating'] ?? 0.0;

          // Calculate the new aggressive rate, ride count, and rating
          double newAggressiveRate = ((aggressiveRate * rideCount) + driverAggressiveRate) / (rideCount + 1);
          double newRating = ((rating * rideCount) + passengerRating) / (rideCount + 1);
          int newRideCount = rideCount + 1;

          // Update the driver's document with the new aggressive rate, ride count, and rating
          await driverRef.update({
            'aggressiveRate': newAggressiveRate,
            'rideCount': newRideCount,
            'rating': newRating,

          });
          //adding tripHistory
          await FirebaseFirestore.instance.collection('passengers').doc(passengerId).update({'tripHistory': FieldValue.arrayUnion([rideMap])});
          await FirebaseFirestore.instance.collection('drivers').doc(driverId).update({'tripHistory': FieldValue.arrayUnion([rideMap])});

          // Remove the ride map from the ridesMap field
          await FirebaseFirestore.instance.collection('rides').doc('ESsJfkjGFRASotvFBna1').update({'ridesMap.$driverId': FieldValue.delete(),});

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
      }
    } catch (error) {
      // Show an error message if updating the ride document fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update ride document')),
      );
    }
  }
}
