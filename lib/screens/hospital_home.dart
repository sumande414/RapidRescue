import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rapid_rescue/screens/accepted_request_screen.dart';
import 'package:rapid_rescue/screens/expired_request_screen.dart';
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
                  label: "Incomming Requests"),
              NavigationDestination(
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: (pageIndex == 1) ? Colors.black : null,
                  ),
                  label: "Accepted Requests"),
              NavigationDestination(
                  icon: Icon(Icons.cancel_sharp,
                      color: (pageIndex == 2) ? Colors.black : null),
                  label: "Expired Requests"),
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
          Column(children: [
            Expanded(
              flex: 5,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                      // height: 380,
                      decoration: BoxDecoration(
                          color: PRIMARY_CARD_BACKGROUND_COLOR,
                          borderRadius: BorderRadius.circular(30)),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          const Text("Incoming Requests",
                              style: TextStyle(color: Colors.green)),
                          Expanded(
                              // width: double.infinity,
                              // height: 290,
                              child: ListView.builder(
                                  itemCount: openRequests.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 1, 8, 1),
                                        child: Card(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Row(children: [
                                                  SizedBox(
                                                    width: 220,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            openRequests[index]
                                                                .datetime
                                                                .substring(
                                                                    0,
                                                                    openRequests[
                                                                            index]
                                                                        .datetime
                                                                        .lastIndexOf(
                                                                            '.')),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .red[900])),
                                                        Text(
                                                            "Name: ${openRequests[index].name}"),
                                                        Text(
                                                            "Email: ${openRequests[index].email}"),
                                                        Text(
                                                            "Phone: ${openRequests[index].phone}"),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'requests')
                                                            .doc(openRequests[
                                                                    index]
                                                                .email)
                                                            .update({
                                                          'status': 'accepted',
                                                          'hospitalName': widget
                                                              .hospital.name,
                                                          'hospitalEmail':
                                                              widget.hospital
                                                                  .email,
                                                          'hospitalPhone':
                                                              widget.hospital
                                                                  .phone
                                                        });
                                                        setState(() {
                                                          openRequests
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      icon: const Icon(
                                                          Icons.check)),
                                                  IconButton(
                                                      onPressed: () {},
                                                      icon:
                                                          const Icon(Icons.map))
                                                ]))));
                                  })),
                        ]),
                      ))),
            )
          ]),
          AcceptedRequestScreen(acceptedRequests: acceptedRequests),
          ExpiredRequestScreen(expiredRequests: expiredRequests)
        ][pageIndex]);
  }
}
