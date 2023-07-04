class User {
  final String uid;
  final String name;
  final String contactNumber;
  String address;
  final String userType;
  int rideNumbers;
  final String picUrl;

  User({
    required this.uid,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.userType,
    required this.rideNumbers,
    required this.picUrl,
  });
}

class UserData extends User {
  UserData({
    required String uid,
    required String name,
    required String contactNumber,
    required String address,
    required String userType,
    required int rideNumbers,
    required String picUrl,
  }) : super(
    uid: uid,
    name: name,
    contactNumber: contactNumber,
    address: address,
    userType: 'Passenger',
    rideNumbers: rideNumbers,
    picUrl: picUrl,
  );
}

class UserDData extends UserData {
  final String? availability;
  final String? vehicleInfo;
  final String? driverLicense;
  final int? rating;

  UserDData({
    required String uid,
    required String name,
    required String contactNumber,
    required String address,
    required String userType,
    required int rideNumbers,
    required String picUrl,
    this.availability,
    this.vehicleInfo,
    this.driverLicense,
    this.rating,
  }) : super(
    uid: uid,
    name: name,
    contactNumber: contactNumber,
    address: address,
    userType: 'Driver',
    rideNumbers: rideNumbers,
    picUrl: picUrl,
  );
}
