import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rapid_rescue/screens/accepted_request_screen.dart';
import 'package:rapid_rescue/screens/expired_request_screen.dart';
import 'package:rapid_rescue/screens/incoming_request_screen.dart';
import '../constants/text_styles.dart';
import '../model/hospital.dart';
import '../constants/colors.dart';
import '../model/request.dart';

class HospitalHomePage extends StatefulWidget {
  HospitalHomePage({super.key, required this.hospital});
  Hospital hospital;

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  List<Request> openRequests = [];
  List<Request> acceptedRequests = [];
  List<Request> expiredRequests = [];

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('requests')
        .snapshots()
        .listen((event) {
      openRequests = [];
      acceptedRequests = [];
      expiredRequests = [];
      event.docs.map(
        (e) {
          // print(Geolocator.distanceBetween(widget.hospital.latitude, widget.hospital.longitude, e['lattitude'], e['longitude']));

          setState(() {
            if (e['status'] == 'open' &&
                Geolocator.distanceBetween(
                        widget.hospital.latitude,
                        widget.hospital.longitude,
                        e['lattitude'],
                        e['longitude']) <=
                    5000) {
              openRequests.add(Request.fromDb(e));
            } else if (e['status'] == 'accepted') {
              openRequests
                  .removeWhere((element) => element.email == e['email']);
              if (e['hospitalEmail'] ==
                  FirebaseAuth.instance.currentUser!.email) {
                acceptedRequests.add(Request.fromDb(e));
              } else {
                expiredRequests.add(Request.fromDb(e));
              }
            } else if (e['status'] == 'completed' &&
                Geolocator.distanceBetween(
                        widget.hospital.latitude,
                        widget.hospital.longitude,
                        e['lattitude'],
                        e['longitude']) <=
                    5000) {
              acceptedRequests
                  .removeWhere((element) => element.email == e['email']);
            }
          });
        },
      ).toList();
    });

    super.initState();
  }

  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: NavigationBar(
            backgroundColor: PRIMARY_BACKGROUND_COLOR,
            selectedIndex: pageIndex,
            onDestinationSelected: (value) {
              setState(() {
                pageIndex = value;
              });
            },
            destinations: [
              NavigationDestination(
                  icon: Icon(Icons.downloading_rounded,
                      color: (pageIndex == 0) ? Colors.black : null),
                  label: "Incomming"),
              NavigationDestination(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: (pageIndex == 1) ? Colors.black : null,
                  ),
                  label: "Accepted"),
              NavigationDestination(
                  icon: Icon(Icons.cancel_sharp,
                      color: (pageIndex == 2) ? Colors.black : null),
                  label: "Expired"),
            ]),
        appBar: AppBar(
          leading: DrawerButton(),
          title: Center(child: Text("Rapid Rescue", style: CARD_HEAD)),
          backgroundColor: Colors.transparent,
          actions: [
            PopupMenuButton(
                icon: CircleAvatar(
                  backgroundColor: PRIMARY_CARD_BACKGROUND_COLOR,
                  child: Text(widget.hospital.name[0],
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
                            widget.hospital.name[0].toUpperCase(),
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
                          widget.hospital.name.toUpperCase(),
                          style: HOSPITAL_HEADING,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      enabled: false,
                      child: Center(
                        child: Text(
                          widget.hospital.email,
                          style: HOSPITAL_SUB_HEADING,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      enabled: false,
                      child: Center(
                        child: Text(
                          widget.hospital.phone,
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
                            //  height: 50,
                            //  width: 150,
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
        body: [
          IncomingRequestScreen(openRequests: openRequests, hospital: widget.hospital),
          AcceptedRequestScreen(acceptedRequests: acceptedRequests),
          ExpiredRequestScreen(expiredRequests: expiredRequests)
        ][pageIndex]);
  }
}
