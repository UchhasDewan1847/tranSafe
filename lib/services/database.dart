import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transafe/models/Driver.dart';
import 'package:transafe/models/Ride.dart';

// class DatabaseService{
//   final String? uid;
//   DatabaseService({this.uid});
//   final CollectionReference users = FirebaseFirestore.instance.collection('Users');
//
//   Future udpdateUserData(String Name, String email,int phone,String photourl) async{
//     return await users.doc(uid).set({
//       'Name':Name,
//       'Email': email,
//       'Phone Number': phone,
//       'Photo Url': photourl,
//     });
//   }
// }


class RideDatabaseService {
  final String rid;
  RideDatabaseService({required this.rid});

  final CollectionReference rideCollection = FirebaseFirestore.instance.collection('rides');

  Future<void> updateRideData(String starting, String destination, double price, int available) async {
    return await rideCollection.doc(rid).set({
      'starting': starting,
      'destination': destination,
      'Price': price,
      'available': available,
    });
  }

  List<RideData> _rideDataFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;

      if (data != null) {
        return RideData(
          rid: doc.id,
          starting: data['starting'] as String?,
          destination: data['destination'] as String?,
          Price: data['Price'] as double?,
          available: data['available'] as int?,
        );
      } else {
        // Handle the case when the document data is null (optional)
        // You can return a default RideData or handle the situation as needed.
        return RideData(
          rid: doc.id,
          starting: null,
          destination: null,
          Price: null,
          available: null,
        );
      }
    }).toList();
  }

  Stream<List<RideData>> get rides {
    return rideCollection.snapshots().map(_rideDataFromSnapshot);
  }
}

class UserDatabaseService {
  final String uid;

  UserDatabaseService({required this.uid});

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(
      String name,
      String location,
      String contactNumber,
      String address,
      int rideNumbers,
      String picUrl) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'location': location,
      'contactNumber': contactNumber,
      'address': address,
      'userType': 'Passenger',
      'rideNumbers': rideNumbers,
      'picUrl': picUrl,
    });
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      return UserData(
        uid: uid,
        name: data['name'] as String,
        contactNumber: data['contactNumber'] as String,
        address: data['address'] as String,
        userType: 'Passenger',
        rideNumbers: data['rideNumbers'] as int,
        picUrl: data['picUrl'] as String,
      );
    }
    return UserData(
      uid: uid,
      name: '',
      contactNumber: '',
      address: '',
      userType: 'Passenger',
      rideNumbers: 0,
      picUrl: '',
    );
  }

  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}

class UserDDatabaseService {
  final String uid;

  UserDDatabaseService({required this.uid});

  final CollectionReference userDCollection =
  FirebaseFirestore.instance.collection('usersD');

  Future<void> updateUserDData(
      String name,
      String contactNumber,
      String address,
      List<String> rideNumbers,
      String picUrl,
      String availability,
      String vehicleInfo,
      String driverLicense,
      int rating) async {
    return await userDCollection.doc(uid).set({
      'name': name,
      'contactNumber': contactNumber,
      'address': address,
      'userType': 'Driver',
      'rideNumbers': rideNumbers,
      'picUrl': picUrl,
      'availability': availability,
      'vehicleInfo': vehicleInfo,
      'driverLicense': driverLicense,
      'rating': rating,
    });
  }

  UserDData _userDDataFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      return UserDData(
        uid: uid,
        name: data['name'] as String,
        contactNumber: data['contactNumber'] as String,
        address: data['address'] as String,
        userType: 'Driver',
        rideNumbers: data['rideNumbers'] as int,
        picUrl: data['picUrl'] as String,
        availability: data['availability'] as String,
        vehicleInfo: data['vehicleInfo'] as String,
        driverLicense: data['driverLicense'] as String,
        rating: data['rating'] as int,
      );
    }
    return UserDData(
      uid: uid,
      name: '',
      contactNumber: '',
      address: '',
      userType: 'Driver',
      rideNumbers:0,
      picUrl: '',
      availability: '',
      vehicleInfo: '',
      driverLicense: '',
      rating: 0,
    );
  }

  Stream<UserDData> get userDData {
    return userDCollection.doc(uid).snapshots().map(_userDDataFromSnapshot);
  }
}
