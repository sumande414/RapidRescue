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
          setState((){
            if(e['status']=='completed'){
            widget.expiredRequests.removeWhere((element) => element.email == e['email']);
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
        title: Text("Expired Requests", style: CARD_HEAD,),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: widget.expiredRequests.length,
        itemBuilder: (context,index){
          return RequestCard(name: widget.expiredRequests[index].name, email: widget.expiredRequests[index].email, phone: widget.expiredRequests[index].phone,datetime: widget.expiredRequests[index].datetime,isExpiredScreen: true,);
      })
    );
  }
}