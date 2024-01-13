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
  Request(
      {required this.email,
      required this.name,
      required this.phone,
      required this.datetime,
      required this.status,
      required this.hospitalName,
      required this.hospitalEmail,
      required this.hospitalPhone,});

  factory Request.fromDb(DocumentSnapshot<Map<String, dynamic>> data) =>
      Request(
          email: data['email'],
          name: data['name'],
          phone: data['phone'],
          datetime: data['datetime'],
          status: data['status'],
          hospitalName:data['hospitalName'],
          hospitalEmail:data['hospitalEmail'],
          hospitalPhone:data['hospitalPhone']);
}
