import 'package:cloud_firestore/cloud_firestore.dart';

class Hospital {
  String email;
  String name;
  String phone;
  double latitude;
  double longitude;
  Hospital(
      {required this.email,
      required this.name,
      required this.phone,
      required this.latitude,
      required this.longitude});

  factory Hospital.fromDb(DocumentSnapshot<Map<String, dynamic>> data) =>
      Hospital(email: data['email'], name: data['name'], phone: data['phone'], latitude: data['lattitude'], longitude:data['longitude']);
}
