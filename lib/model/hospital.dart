import 'package:cloud_firestore/cloud_firestore.dart';

class Hospital{
  String email;
  String name;
  String phone;
  Hospital({required this.email,required this.name,required this.phone});

  factory Hospital.fromDb(DocumentSnapshot<Map<String,dynamic>> data) => Hospital(email: data['email'],name:data['name'],phone:data['phone']);
}