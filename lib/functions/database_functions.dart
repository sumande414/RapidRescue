import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

addAll(
    {
    required String email,
    required String type,
    }
    ) async {
  try {
    await FirebaseFirestore.instance
        .collection('all')
        .doc(email)
        .set({
      'email':email,
      'type':type

    });
  } catch (e) {
    Fluttertoast.showToast(msg: "Firestore Error: ${e.toString()}");
  }
}

addHospital(
    {
    required String email,
    required String name,
    required String phone,
    required Position hospitalCoordinates
    }
    ) async {
  try {
    await FirebaseFirestore.instance
        .collection('hospitals')
        .doc(email)
        .set({
      'name': name,
      'email': email,
      'phone': phone,
      'lattitude' : hospitalCoordinates.latitude,
      'longitude' : hospitalCoordinates.longitude

    });
  } catch (e) {
    Fluttertoast.showToast(msg: "Firestore Error: ${e.toString()}");
  }
}

addUser(
    {
    required String name,
    required String email,
    required String phone,

  }) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .set({'username': name, 'email': email, 'phone':phone});
  } catch (e) {
    Fluttertoast.showToast(msg: "Firestore Error: ${e.toString()}");
  }
}

addRequest(
    {
    required String email,
    required String name,
    required String phone,
    required Position userCoordinates,
    required String datetime,
    required String status,
    required String hospitalName,
    required String hospitalEmail,
    required String hospitalPhone,
    }
    ) async {
  try {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(email)
        .set({
      'name': name,
      'email': email,
      'phone': phone,
      'datetime' : datetime,
      'lattitude' : userCoordinates.latitude,
      'longitude' : userCoordinates.longitude,
      'status' : status,
      'hospitalName' : hospitalName,
      'hospitalEmail' : hospitalEmail,
      'hospitalPhone' : hospitalPhone,
    });
  } catch (e) {
    Fluttertoast.showToast(msg: "Firestore Error: ${e.toString()}");
  }
}