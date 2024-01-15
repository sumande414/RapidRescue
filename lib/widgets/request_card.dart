import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
   const RequestCard({super.key, required this.name, required this.email, required this.phone,required this.datetime, this.isExpiredScreen});
  final String name;
  final bool? isExpiredScreen;
  final String email;
  final String phone;
  final String datetime;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8,1,8,1),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(children: [
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(datetime.substring(0,datetime.lastIndexOf('.')),style:TextStyle(color:Colors.red[900])),
                Text("Name: $name"),
                Text("Email: $email"),
                Text("Phone: $phone"),
              ],),
            ),
            const Spacer(),
            (isExpiredScreen==true)?Container():IconButton(onPressed: (){
              FirebaseFirestore.instance.collection('requests').doc(email).update({'status':'completed'});
            }, icon: const Icon(Icons.check)),
            (isExpiredScreen==true)?Container():IconButton(onPressed: (){}, icon: const Icon(Icons.map))
          ],),
        )
      ),
    );
  }
}