import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser{
  String email;
  String name;
  String phone;
  AppUser({required this.email,required this.name,required this.phone});

  factory AppUser.fromDb(DocumentSnapshot<Map<String,dynamic>> data) => AppUser(email: data['email'],name:data['username'],phone:data['phone']);
}