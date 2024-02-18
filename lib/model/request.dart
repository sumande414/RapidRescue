import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  String datetime;
  String email;
  String name;
  String phone;
  String status;
  String hospitalName;
  String hospitalEmail;
  String hospitalPhone;
  double lat;
  double lng;
  double? hospitalLat;
  double? hospitalLong;
  Request(
      {required this.email,
      required this.name,
      required this.phone,
      required this.datetime,
      required this.status,
      required this.hospitalName,
      required this.hospitalEmail,
      required this.hospitalPhone,
      required this.lat,
      required this.lng,
      required this.hospitalLat,
      required this.hospitalLong});

  factory Request.fromDb(DocumentSnapshot<Map<String, dynamic>> data) =>
      Request(
          email: data['email'],
          name: data['name'],
          phone: data['phone'],
          datetime: data['datetime'],
          status: data['status'],
          hospitalName: data['hospitalName'],
          hospitalEmail: data['hospitalEmail'],
          hospitalPhone: data['hospitalPhone'],
          lat: data['lattitude'],
          lng: data['longitude'],
          hospitalLat: data['hospitalLat'],
          hospitalLong: data['hospitalLong']);
}
