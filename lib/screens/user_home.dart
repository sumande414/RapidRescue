import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rapid_rescue/functions/database_functions.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../model/request.dart';
import '../model/user.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  Future<AppUser>? user;
  Request? request;

  Position? _currentPosition;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  void initState() {
    user = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) => AppUser.fromDb(value));
    // request = FirebaseFirestore.instance.collection('requests').doc(FirebaseAuth.instance.currentUser!.email).get().then((value) => Request.fromDb(value));
    FirebaseFirestore.instance
        .collection('requests')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        request = Request.fromDb(querySnapshot);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: PRIMARY_BACKGROUND_COLOR,
        body: FutureBuilder(
            future: user,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var user = snapshot.data!;
                return Column(children: [
                  Container(
                      height: 370,
                      width: double.infinity,
                      color: Colors.white.withOpacity(.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: CircleAvatar(
                              backgroundColor: PRIMARY_BACKGROUND_COLOR,
                              radius: 90,
                              child: Text(user.name[0].toUpperCase(),
                                  style: AVATAR),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(user.name.toUpperCase(),
                              style: HOSPITAL_HEADING),
                          Text(user.email, style: HOSPITAL_SUB_HEADING),
                          Text(user.phone, style: HOSPITAL_SUB_HEADING),
                          IconButton(onPressed: (){
                            FirebaseAuth.instance.signOut();
                          }, icon: Icon(Icons.logout))
                        ],
                      )),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      _getCurrentPosition();
                      print(_currentPosition);
                      if (_currentPosition != null) {
                        addRequest(
                            email: user.email,
                            name: user.name,
                            phone: user.phone,
                            userCoordinates: _currentPosition!,
                            datetime: DateTime.now().toString(),
                            status: "open");
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                title: Text("Fetching Location..."),
                                actions: [
                                  Center(child: CircularProgressIndicator())
                                ],
                              );
                            });
                      }
                    },
                    child: Container(
                      height: 70,
                      width: 350,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                          child: Text("REQUEST AMBULANCE", style: CARD_BUTTON)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                      height: 350,
                      width: 300,
                      decoration: BoxDecoration(
                          color: PRIMARY_CARD_BACKGROUND_COLOR,
                          borderRadius: BorderRadius.circular(50)),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            const Text("Request Status",
                                style: TextStyle(color: Colors.green)),
                            const SizedBox(height: 10),
                            Card(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: (request!=null)?Column(
                                children: [
                                  Text("Name: ${request!.name}"),
                                  Text("Email: ${request!.email}"),
                                  Text("Phone: ${request!.phone}"),
                                  Text("${request!.status.toUpperCase()}",
                                      style: TextStyle(fontSize: 30))
                                ],
                              ):Center(child: Text("No data found"),),
                            ))
                          ])))
                ]);
              } else {
                return const Center(
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator()),
                );
              }
            }));
  }
}
