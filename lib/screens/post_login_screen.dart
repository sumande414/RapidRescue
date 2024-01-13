import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rapid_rescue/screens/hospital_home.dart';
import 'package:rapid_rescue/screens/user_home.dart';

class PostLoginScreen extends StatefulWidget {
  const PostLoginScreen({super.key});

  @override
  State<PostLoginScreen> createState() => _PostLoginScreenState();
}

class _PostLoginScreenState extends State<PostLoginScreen> {
  String? type;
  @override
  void initState() {
    FirebaseFirestore.instance.collection('all').doc(FirebaseAuth.instance.currentUser!.email).get().then((value) {
      do{
        setState(() {
          type = value['type'];
        });       
      }
      while(type==null);
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if(type == "hospital"){
      return HospitalHomePage();
    }
    else if(type == "user"){
      return UserHomePage();
    }
    else{
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

  }
}