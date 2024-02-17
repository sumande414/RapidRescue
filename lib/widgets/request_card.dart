import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rapid_rescue/model/hospital.dart';
import 'package:rapid_rescue/screens/map_screen.dart';

class RequestCard extends StatelessWidget {
  RequestCard(
      {super.key,
      required this.name,
      required this.email,
      required this.phone,
      required this.datetime,
      this.isExpiredScreen,
      required this.lat,
      required this.lng,
      this.hospital});
  final String name;
  final bool? isExpiredScreen;
  final String email;
  final String phone;
  final String datetime;
  final double lat;
  final double lng;
  Hospital? hospital;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 1, 8, 1),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            SizedBox(
              width: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(datetime.substring(0, datetime.lastIndexOf('.')),
                      style: TextStyle(color: Colors.red[900])),
                  Text("Name: $name"),
                  Text("Email: $email"),
                  Text("Phone: $phone"),
                ],
              ),
            ),
            const Spacer(),
            (isExpiredScreen == true)
                ? Container()
                : IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('requests')
                          .doc(email)
                          .update({'status': 'completed'});
                    },
                    icon: const Icon(Icons.check)),
            (isExpiredScreen == true)
                ? Container()
                : IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapScreen(
                                    lat: lat,
                                    lng: lng,
                                    hospital: hospital,
                                  )));
                    },
                    icon: const Icon(Icons.map))
          ],
        ),
      )),
    );
  }
}
