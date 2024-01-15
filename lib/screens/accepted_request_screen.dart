import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../widgets/request_card.dart';

import '../model/request.dart';

class AcceptedRequestScreen extends StatefulWidget {
  AcceptedRequestScreen({super.key, required this.acceptedRequests});
    List<Request> acceptedRequests;
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
          setState((){
            if(e['status']=='completed'){
            widget.acceptedRequests.removeWhere((element) => element.email == e['email']);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Accepted Requests", style: CARD_HEAD,),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: widget.acceptedRequests.length,
        itemBuilder: (context,index){
          return RequestCard(name: widget.acceptedRequests[index].name, email: widget.acceptedRequests[index].email, phone: widget.acceptedRequests[index].phone);
      })
    );
  }
}