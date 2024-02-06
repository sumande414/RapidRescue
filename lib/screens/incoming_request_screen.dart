import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rapid_rescue/constants/colors.dart';
import 'package:rapid_rescue/constants/text_styles.dart';
import 'package:rapid_rescue/model/hospital.dart';
import 'package:rapid_rescue/model/request.dart';
import 'package:rapid_rescue/screens/map_screen.dart';

class IncomingRequestScreen extends StatefulWidget {
  const IncomingRequestScreen(
      {super.key, required this.openRequests, required this.hospital});
  final List<Request> openRequests;
  final Hospital hospital;
  @override
  State<IncomingRequestScreen> createState() => _IncomingRequestScreenState();
}

class _IncomingRequestScreenState extends State<IncomingRequestScreen> {
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
                    Text("Incoming Requests", style: REQUEST_TEXT_STYLE),
                    Expanded(
                        // width: double.infinity,
                        // height: 290,
                        child: ListView.builder(
                            itemCount: widget.openRequests.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 1, 8, 1),
                                  child: Card(
                                      child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(children: [
                                            SizedBox(
                                              width: 220,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      widget.openRequests[index]
                                                          .datetime
                                                          .substring(
                                                              0,
                                                              widget
                                                                  .openRequests[
                                                                      index]
                                                                  .datetime
                                                                  .lastIndexOf(
                                                                      '.')),
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[900])),
                                                  Text(
                                                      "Name: ${widget.openRequests[index].name}"),
                                                  Text(
                                                      "Email: ${widget.openRequests[index].email}"),
                                                  Text(
                                                      "Phone: ${widget.openRequests[index].phone}"),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection('requests')
                                                      .doc(widget
                                                          .openRequests[index]
                                                          .email)
                                                      .update({
                                                    'status': 'accepted',
                                                    'hospitalName':
                                                        widget.hospital.name,
                                                    'hospitalEmail':
                                                        widget.hospital.email,
                                                    'hospitalPhone':
                                                        widget.hospital.phone
                                                  });
                                                  setState(() {
                                                    widget.openRequests
                                                        .removeAt(index);
                                                  });
                                                },
                                                icon: const Icon(Icons.check)),
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MapScreen(lat: widget
                                                          .openRequests[index]
                                                          .lat,lng:widget
                                                          .openRequests[index]
                                                          .lng,),
                                                      ));
                                                },
                                                icon: const Icon(Icons.map))
                                          ]))));
                            })),
                  ]),
                ))),
      )
    ]);
  }
}
