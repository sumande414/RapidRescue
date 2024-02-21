import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:rapid_rescue/functions/database_functions.dart';

import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../model/request.dart';
import '../model/user.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key, required this.user});
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

  TextStyle getDefaultTextStyle() {
    return const TextStyle(
      fontSize: 10,
      backgroundColor: Colors.transparent,
      color: Colors.black,
    );
  }

  Container buildTextWidget(String word) {
    return Container(
        alignment: Alignment.center,
        child: Text(word,
            textAlign: TextAlign.center, style: getDefaultTextStyle()));
  }

  Marker buildMarker(LatLng coordinates, String word) {
    return Marker(
        point: coordinates,
        width: 100,
        height: 12,
        child: buildTextWidget(word));
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Rapid Rescue", style: CARD_HEAD),
        backgroundColor: Colors.transparent,
        actions: [
          PopupMenuButton(
              icon: CircleAvatar(
                backgroundColor: PRIMARY_CARD_BACKGROUND_COLOR,
                child: Text(widget.user.name[0],
                    style: TextStyle(color: Colors.white)),
              ),
              color: PRIMARY_CARD_BACKGROUND_COLOR,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: PRIMARY_BACKGROUND_COLOR,
                        radius: 90,
                        child: Text(
                          widget.user.name[0].toUpperCase(),
                          style: AVATAR,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    enabled: false,
                    child: Center(
                      child: Text(
                        widget.user.name.toUpperCase(),
                        style: HOSPITAL_HEADING,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    enabled: false,
                    child: Center(
                      child: Text(
                        widget.user.email,
                        style: HOSPITAL_SUB_HEADING,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    enabled: false,
                    child: Center(
                      child: Text(
                        widget.user.phone,
                        style: HOSPITAL_SUB_HEADING,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                      },
                      enabled: true,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("LOGOUT", style: BOTTON_TEXT_STYLE),
                            ),
                          ),
                        ),
                      ))
                ];
              }),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: PRIMARY_BACKGROUND_COLOR,
      body: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    color: PRIMARY_CARD_BACKGROUND_COLOR,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Card(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: (request != null)
                        ? Column(
                            children: [
                              Text("${request!.status.toUpperCase()}",
                                  style: const TextStyle(fontSize: 30)),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("User",style: TextStyle(fontSize: width/30, fontWeight: FontWeight.bold)),
                                      Text(
                                        "${request!.name}",
                                        style: TextStyle(fontSize: width / 30),
                                      ),
                                      Text("${request!.email}",
                                          style:
                                              TextStyle(fontSize: width / 30)),
                                      Text("${request!.phone}",
                                          style:
                                              TextStyle(fontSize: width / 30)),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Hospital",style: TextStyle(fontSize: width/30,fontWeight: FontWeight.bold)),
                                      Text("${request!.hospitalName}",
                                          style:
                                              TextStyle(fontSize: width / 30)),
                                      Text("${request!.hospitalEmail}",
                                          style:
                                              TextStyle(fontSize: width / 30)),
                                      Text("${request!.hospitalPhone}",
                                          style:
                                              TextStyle(fontSize: width / 30)),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          )
                        : const Center(
                            child: Text("No data found"),
                          ),
                  )),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: double.infinity,
                      child: (request != null && request!.hospitalLat != null)
                          ? FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(request!.hospitalLat!,
                                    request!.hospitalLong!),
                                initialZoom: 16.5,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.spyder.rapidrescue',
                                ),
                                CircleLayer(circles: [
                                  CircleMarker(
                                    point: LatLng(request!.hospitalLat!,
                                        request!.hospitalLong!),
                                    radius: 5,
                                    color: Colors.red,
                                  ),
                                ]),
                                MarkerLayer(
                                  markers: [
                                    buildMarker(
                                        LatLng(request!.hospitalLat! - 0.0001,
                                            request!.hospitalLong!),
                                        "Hospital"),
                                  ],
                                )
                              ],
                            )
                          : (request == null)
                              ? Center(child: Text("No request found :)"))
                              : (request!.status == "open")
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.green),
                                    )
                                  : null,
                    ),
                  ),
                ])),
          ),
        )
      ]),
      floatingActionButton: GestureDetector(
        onTap: (request == null || request!.status == 'completed')
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
                      hospitalLat: null,
                      hospitalLong: null);
                } else {
                  Fluttertoast.showToast(
                      msg: "Fetching Location... Please wait...");
                }
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 70,
            width: MediaQuery.of(context).size.width / 1.15,
            decoration: BoxDecoration(
                color: (request == null || request!.status == 'completed')
                    ? Colors.green
                    : Colors.grey,
                borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text("REQUEST AMBULANCE", style: CARD_BUTTON)),
          ),
        ),
      ),
    );
  }
}
