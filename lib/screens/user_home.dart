import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rapid_rescue/functions/database_functions.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../model/request.dart';
import '../model/user.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key,required this.user});
  final AppUser user;
  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
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
        appBar: AppBar(
          leading: DrawerButton(),
          title: Center(child: Text("Rapid Rescue", style: CARD_HEAD)),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout))
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: PRIMARY_BACKGROUND_COLOR,
        body: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 320,
                          width: double.infinity,
                          color: Colors.white.withOpacity(.1),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  backgroundColor: PRIMARY_BACKGROUND_COLOR,
                                  radius: 90,
                                  child: Text(widget.user.name[0].toUpperCase(),
                                      style: AVATAR),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(widget.user.name.toUpperCase(),
                                  style: HOSPITAL_HEADING),
                              Text(widget.user.email, style: HOSPITAL_SUB_HEADING),
                              Text(widget.user.phone, style: HOSPITAL_SUB_HEADING),
                            ],
                          )),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap:
                            (request == null || request!.status == 'completed')
                                ? () {
                                    _getCurrentPosition();
                                    print(_currentPosition);
                                    if (_currentPosition != null) {
                                      addRequest(
                                        email: widget.user.email,
                                        name: widget.user.name,
                                        phone: widget.user.phone,
                                        userCoordinates: _currentPosition!,
                                        datetime: DateTime.now().toString(),
                                        status: "open",
                                        hospitalName: "null",
                                        hospitalEmail: "null",
                                        hospitalPhone: "null",
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Fetching Location... Please wait...");
                                    }
                                  }
                                : null,
                        child: Container(
                          height: 70,
                          width: 350,
                          decoration: BoxDecoration(
                              color: (request == null ||
                                      request!.status == 'completed')
                                  ? Colors.green
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                              child: Text("REQUEST AMBULANCE",
                                  style: CARD_BUTTON)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                          height: 295,
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
                                  child: (request != null)
                                      ? Column(
                                          children: [
                                            Text("Name: ${request!.name}"),
                                            Text("Email: ${request!.email}"),
                                            Text("Phone: ${request!.phone}"),
                                            Text(
                                                "${request!.status.toUpperCase()}",
                                                style: const TextStyle(
                                                    fontSize: 30)),
                                            Text(
                                                "Name: ${request!.hospitalName}"),
                                            Text(
                                                "Email: ${request!.hospitalEmail}"),
                                            Text(
                                                "Phone: ${request!.hospitalPhone}"),
                                          ],
                                        )
                                      : const Center(
                                          child: Text("No data found"),
                                        ),
                                ))
                              ])))
                    ])
              );
  }
}
