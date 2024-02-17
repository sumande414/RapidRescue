import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rapid_rescue/constants/colors.dart';
import 'package:rapid_rescue/constants/text_styles.dart';
import 'package:rapid_rescue/widgets/request_card.dart';

import '../model/request.dart';

class ExpiredRequestScreen extends StatefulWidget {
  const ExpiredRequestScreen({super.key, required this.expiredRequests});
  final List<Request> expiredRequests;
  @override
  State<ExpiredRequestScreen> createState() => _ExpiredRequestScreenState();
}

class _ExpiredRequestScreenState extends State<ExpiredRequestScreen> {
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
              widget.expiredRequests
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
                         Text("Expired Requests",
                            style: REQUEST_TEXT_STYLE),
                        Expanded(
                            // width: double.infinity,
                            // height: 290,
                            child: ListView.builder(
                                itemCount: widget.expiredRequests.length,
                                itemBuilder: (context, index) {
                                  return RequestCard(
                                    name: widget.expiredRequests[index].name,
                                    email: widget.expiredRequests[index].email,
                                    phone: widget.expiredRequests[index].phone,
                                    datetime:
                                        widget.expiredRequests[index].datetime,
                                    isExpiredScreen: true,
                                    lat: widget
                                          .expiredRequests[index].lat,
                                    lng:widget
                                          .expiredRequests[index].lng
                                    
                                  );
                                }))
                      ])))))
    ]);
  }
}
