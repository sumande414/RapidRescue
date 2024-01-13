import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/text_styles.dart';
import '../model/hospital.dart';
import '../constants/colors.dart';
import '../model/request.dart';

class HospitalHomePage extends StatefulWidget {
  const HospitalHomePage({super.key});

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  Future<Hospital>? hsptl;
  List<Request> openRequests = [];
  List<Request> acceptedRequests = [];
  @override
  void initState() {
    hsptl = FirebaseFirestore.instance
        .collection('hospitals')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) => Hospital.fromDb(value));
    FirebaseFirestore.instance
        .collection('requests')
        .snapshots()
        .listen((event) {
      event.docs.map(
        (e) {
          print(e);
          setState(() {
            if (e['status'] == 'open' &&
                openRequests
                    .where((element) => element.email == e['email'])
                    .isEmpty) {
              openRequests.add(Request.fromDb(e));
            }
            if (e['status'] == 'accepted') {
              print("reached");
              openRequests.removeWhere((item) => item.email == e['email']);
              acceptedRequests.add(Request.fromDb(e));
            }
          });
        },
      ).toList();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: PRIMARY_BACKGROUND_COLOR,
        body: FutureBuilder(
            future: hsptl,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var hospital = snapshot.data!;
                return Column(children: [
                  Container(
                      height: 380,
                      width: double.infinity,
                      color: Colors.white.withOpacity(.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: CircleAvatar(
                              backgroundColor: PRIMARY_BACKGROUND_COLOR,
                              radius: 90,
                              child: Text(hospital.name[0].toUpperCase(),
                                  style: AVATAR),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(hospital.name.toUpperCase(),
                              style: HOSPITAL_HEADING),
                          Text(hospital.email, style: HOSPITAL_SUB_HEADING),
                          Text(hospital.phone, style: HOSPITAL_SUB_HEADING),
                          IconButton(
                              onPressed: () {
                                FirebaseAuth.instance.signOut();
                              },
                              icon: Icon(Icons.logout))
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                              color: PRIMARY_CARD_BACKGROUND_COLOR,
                              borderRadius: BorderRadius.circular(30)),
                          width: double.infinity,
                          child: Column(children: [
                            Text("Incoming Requests",
                                style: TextStyle(color: Colors.green)),
                            Container(
                                width: double.infinity,
                                height: 200,
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
                                                              "Name: ${openRequests[index].name}"),
                                                          Text(
                                                              "Email: ${openRequests[index].email}"),
                                                          Text(
                                                              "Phone: ${openRequests[index].phone}"),
                                                        ],
                                                      ),
                                                    ),
                                                    Spacer(),
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
                                                            'status':
                                                                'accepted',
                                                            'hospitalName':
                                                                hospital.name,
                                                            'hospitalEmail':
                                                                hospital.email,
                                                            'hospitalPhone':
                                                                hospital.phone
                                                          });
                                                          setState(() {
                                                            openRequests
                                                                .removeAt(
                                                                    index);
                                                          });
                                                        },
                                                        icon:
                                                            Icon(Icons.check)),
                                                    IconButton(
                                                        onPressed: () {},
                                                        icon: Icon(Icons.map))
                                                  ]))));
                                    }))
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
