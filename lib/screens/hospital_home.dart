import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rapid_rescue/screens/accepted_request_screen.dart';
import 'package:rapid_rescue/screens/expired_request_screen.dart';
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
  List<Request> expiredRequests = [];

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
          openRequests=[];
          acceptedRequests=[];
          expiredRequests=[];
      event.docs.map(
        (e) {
          setState((){
            if(e['status']=='open'){
            openRequests.add(Request.fromDb(e));
          }
          else if(e['status']=='accepted'){
            openRequests.removeWhere((element) => element.email == e['email']);
            if(e['hospitalEmail']==FirebaseAuth.instance.currentUser!.email)
            {
            acceptedRequests.add(Request.fromDb(e));
          } else{
            expiredRequests.add(Request.fromDb(e));
          }
          }else if(e['status']=='completed'){
            acceptedRequests.removeWhere((element) => element.email == e['email']);
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
      appBar: AppBar(leading: DrawerButton(),
      title: Center(child: Text("Rapid Rescue",style:CARD_HEAD)),
      backgroundColor: Colors.transparent,
      actions:[IconButton(onPressed: (){FirebaseAuth.instance.signOut();}, icon: Icon(Icons.logout))],
      iconTheme: const IconThemeData(color:Colors.white),),
        backgroundColor: PRIMARY_BACKGROUND_COLOR,
        body: FutureBuilder(
            future: hsptl,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var hospital = snapshot.data!;
                return Column(children: [
                  Container(
                      height: 320,
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
                          const SizedBox(height: 15),
                          Text(hospital.name.toUpperCase(),
                              style: HOSPITAL_HEADING),
                          Text(hospital.email, style: HOSPITAL_SUB_HEADING),
                          Text(hospital.phone, style: HOSPITAL_SUB_HEADING),
                          
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          height: 380,
                          decoration: BoxDecoration(
                              color: PRIMARY_CARD_BACKGROUND_COLOR,
                              borderRadius: BorderRadius.circular(30)),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: [
                              const Text("Incoming Requests",
                                  style: TextStyle(color: Colors.green)),
                              SizedBox(
                                  width: double.infinity,
                                  height: 290,
                                  child: ListView.builder(
                                      itemCount: openRequests.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 1, 8, 1),
                                            child: Card(
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Row(children: [
                                                      SizedBox(
                                                        width: 220,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(openRequests[index].datetime.substring(0,openRequests[index].datetime.lastIndexOf('.')),style:TextStyle(color:Colors.red[900])),

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
                                                              'status':
                                                                  'accepted',
                                                              'hospitalName':
                                                                  hospital.name,
                                                              'hospitalEmail':
                                                                  hospital
                                                                      .email,
                                                              'hospitalPhone':
                                                                  hospital.phone
                                                            });
                                                            setState(() {
                                                              openRequests
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons.check)),
                                                      IconButton(
                                                          onPressed: () {},
                                                          icon: const Icon(
                                                              Icons.map))
                                                    ]))));
                                      })),
                              //const Spacer(),
                              Row(
                                children: [
                                  const Spacer(),
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> AcceptedRequestScreen(acceptedRequests:  acceptedRequests)));
                                      },
                                      icon: const Icon(Icons
                                          .playlist_add_check_circle_rounded),
                                      label: const Text("Accepted")),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ExpiredRequestScreen(expiredRequests:  expiredRequests,)));

                                      },
                                      icon: const Icon(Icons
                                          .playlist_add_check_circle_rounded),
                                      label: const Text("Expired")),
                                ],
                              )
                            ]),
                          )))
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
