import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rapid_rescue/model/hospital.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/request_card.dart';

import '../model/request.dart';

class AcceptedRequestScreen extends StatefulWidget {
  AcceptedRequestScreen(
      {super.key, required this.acceptedRequests, required this.hospital});
  List<Request> acceptedRequests;
  Hospital hospital;
  @override
  State<AcceptedRequestScreen> createState() => _AcceptedRequestScreenState();
}

class _AcceptedRequestScreenState extends State<AcceptedRequestScreen> {
  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('requests')
        .snapshots()
        .listen((event) {
      event.docs.map(
        (e) {
          setState(() {
            if (e['status'] == 'completed') {
              widget.acceptedRequests
                  .removeWhere((element) => element.email == e['email']);
            }
          });
        },
      ).toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
                        Text("Accepted Requests", style: REQUEST_TEXT_STYLE),
                        Expanded(
                            // width: double.infinity,
                            // height: 290,
                            child: ListView.builder(
                                itemCount: widget.acceptedRequests.length,
                                itemBuilder: (context, index) {
                                  return RequestCard(
                                    name: widget.acceptedRequests[index].name,
                                    email: widget.acceptedRequests[index].email,
                                    phone: widget.acceptedRequests[index].phone,
                                    datetime:
                                        widget.acceptedRequests[index].datetime,
                                    lat: widget.acceptedRequests[index].lat,
                                    lng: widget.acceptedRequests[index].lng,
                                    hospital: widget.hospital,
                                  );
                                }))
                      ])))))
    ]);
  }
}
