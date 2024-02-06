import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rapid_rescue/constants/colors.dart';
import 'package:rapid_rescue/model/hospital.dart';
import 'package:rapid_rescue/screens/hospital_home.dart';
import 'package:rapid_rescue/screens/user_home.dart';

import '../model/user.dart';

class PostLoginScreen extends StatefulWidget {
  const PostLoginScreen({super.key});

  @override
  State<PostLoginScreen> createState() => _PostLoginScreenState();
}

class _PostLoginScreenState extends State<PostLoginScreen> {
  String? type;
  Future<Hospital>? hsptl;
  Future<AppUser>? appUser;
  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('all')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      do {
        setState(() {
          type = value['type'];
        });
        if (type == 'hospital') {
          hsptl = FirebaseFirestore.instance
              .collection('hospitals')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .get()
              .then((value) => Hospital.fromDb(value));
        }
        if (type == 'user') {
          appUser = FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .get()
              .then((value) => AppUser.fromDb(value));
        }
      } while (type == null && appUser == null && hsptl == null);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (type == "hospital") {
      return FutureBuilder(
          future: hsptl,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return HospitalHomePage(hospital: snapshot.data!);
            } else {
              return Scaffold(backgroundColor: PRIMARY_BACKGROUND_COLOR,body: Center(child: CircularProgressIndicator()));
            }
          });
    } else if (type == "user") {
      return FutureBuilder(
          future: appUser,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return UserHomePage(user: snapshot.data!);
            } else {
              return Scaffold(backgroundColor: PRIMARY_BACKGROUND_COLOR,body: Center(child: CircularProgressIndicator()));
            }
          });
    } else {
      return Scaffold(
        backgroundColor: PRIMARY_BACKGROUND_COLOR,
        body:const Center(child: CircularProgressIndicator()),
      );
    }
  }
}
