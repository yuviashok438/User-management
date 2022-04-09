import 'dart:convert';
import 'dart:ffi';
// import 'dart:html';
import 'dart:io';

import 'package:b/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'navigation_drawer.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DataBaseHelper dBManager = DataBaseHelper();
  final Future<FirebaseApp> _app = Firebase.initializeApp();

  final referenceDatabase = FirebaseDatabase.instance.reference();
  String myOnesignalAppId = 'e97a4971-1e60-455f-ac49-87c2a78fde2a';
  var playerId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  String? loggedUserFromHomePage;
  String? loggedUserFromHomePagePassword;
  bool isuserLoggedOut = true;
  var _externalUserId;
  bool _enableConsentButton = false;
  String _debugLabelString = "";
  final HttpClient httpClient = HttpClient();
  final String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
  var response1;
  dynamic data;

  final fcmKey =
      "AAAA6Bobp-Q:APA91bG0CDwQyEFZbI4_URL1ZBSpAcy6zzZcdSKRBxa05uUet0S7GxlEhPABHPOzDwptawLHdJBGg08Kes9wE9IRXqJaXr3ZrGYC5GMzC41hJkEcAkJQVth6wNQIUQcbmsiCLUnVLmlt";

  final fcmToken =
      'efo2US3vTnCWGHcroLL8kJ:APA91bEt6d6ZjRLzMkr947LDW3omdaKgqt7l_eW6u1VLFSJ2lC7w3Jfs-Q7tzCsQST6yCMT2H87SmA3_rAfPBpe-F1mEpwMLFJYDi6BSGKb95hBXjK-URpo_afJQB4Fe0h5vHEsR0jUe';
  var fcmTokens = [
    'eaImVb1_QHGZWa-6pq42-O:APA91bGikMES_B6xY_ZDl7uz5QYH3KiPwO_tAresBK8CJWP7ixa4ZGeQRUw02PG-OAXzhdOCDNuhF74iQfxDOAkkPmNcFeX1KHGyESZef8ufe4uwHVWmJ7O29japN-swbi5IWy1NwaaX',
    'efo2US3vTnCWGHcroLL8kJ:APA91bEt6d6ZjRLzMkr947LDW3omdaKgqt7l_eW6u1VLFSJ2lC7w3Jfs-Q7tzCsQST6yCMT2H87SmA3_rAfPBpe-F1mEpwMLFJYDi6BSGKb95hBXjK-URpo_afJQB4Fe0h5vHEsR0jUe',
    'dYDZhsZcRDeqnxPIKmUESA:APA91bFqpyEkpGPTlgy9QZHc40RsMfpXJXxtBJTbqMQPKIqD57QmaXM3L--PGEUQfoyTbdIJ2EnVPGmtAUwa9Vy9c-tsgCIVuUXG7p0sbCJQzQq3dZ4Xehms3dGrKzmNxRJdjUPjE7Js'
  ];

  @override
  void initState() {
    super.initState();
    getToken();

    getLoggedUser();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null) {
        print('OnMessage.listen');
        showDialogue();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new Notification event was published ');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        print('onMessage opened');
        showDialogue();
      }
    });
  }

  getLoggedUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setBool('isuserLoggedOut', isuserLoggedOut);
    String loggedUser = sharedPreferences.getString('loggedUser');
    if (loggedUser != null) {
      try {
        UserModel user = await dBManager.loginUserDetails(loggedUser);
        loggedUserFromHomePage = user.email;
        loggedUserFromHomePagePassword = user.password;
        _externalUserId = user.id;

        sharedPreferences.setString(
            'loggedUserFromHomePagePassword', loggedUserFromHomePagePassword);
        sharedPreferences.setString(
            'loggedUserFromHomePage', loggedUserFromHomePage);
      } catch (e) {
        print('User not found in local database');
      }
    }
  }

  showDialogue() {
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black,
        pageBuilder: (
          BuildContext context,
          Animation one,
          Animation two,
        ) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(20),
              color: Colors.blue,
              child: Column(
                children: <Widget>[
                  Text('New notification arrived'),
                  Center(
                      child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 400,
                      ),
                      RaisedButton(
                          color: Colors.black,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  )),
                ],
              ),
            ),
          );
        });
  }

  showdiallog(String message) async {
    return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
              message,
              style: TextStyle(color: Colors.green),
            ),
            actions: [
              Center(
                child: FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Ok')),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavigationDrawerWidget(),
        appBar: AppBar(
          title: Text('Home page'),
        ),
        body: Center(
          child: Column(
            children: [
              RaisedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return AlertDialog(
                          content: Text(
                            'List of devices',
                            style: TextStyle(color: Colors.green),
                          ),
                          actions: [
                            SingleChildScrollView(
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('tokenId')
                                    .snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    return SingleChildScrollView(
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          itemCount: snapshot.data!.docs.length,
                                          itemBuilder: (context, index) {
                                            DocumentSnapshot documentSnapshot =
                                                snapshot.data!.docs[index];
                                            resizeToAvoidBottomInset:
                                            true;
                                            return FlatButton(
                                                onPressed: () {
                                                  sendFcm(
                                                      'title',
                                                      'body',
                                                      documentSnapshot[
                                                          'tokenId']);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                    documentSnapshot['name']));
                                          }),
                                    );
                                  }
                                  return CircularProgressIndicator();
                                },
                              ),
                            )
                          ],
                        );
                      });
                },
                child: Text('Send Notification '),
              ),
              RaisedButton(
                onPressed: () {
                  sendFcmToParticularTopic('title',
                      'This notification is for particular topic subscriber');
                },
                child: Text('Send Notification to topic'),
              ),
              RaisedButton(
                onPressed: () {
                  sendFcmToAll(
                      'title ', 'This notification is for all ', fcmTokens);
                },
                child: Text('sendFcmToAll'),
              )
            ],
          ),
        )

        //   child: StreamBuilder(
        //     stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //       if (snapshot.hasData) {
        //         return ListView.builder(
        //             itemCount: snapshot.data!.docs.length,
        //             itemBuilder: (context, index) {
        //               DocumentSnapshot documentSnapshot =
        //                   snapshot.data!.docs[index];
        //               return Card(
        //                 child: Column(
        //                   crossAxisAlignment: CrossAxisAlignment.start,
        //                   children: <Widget>[
        //                     Row(
        //                       children: <Widget>[
        //                         Text(
        //                           'Name  :   ',
        //                           style: TextStyle(fontSize: 15),
        //                         ),
        //                         Text(
        //                           documentSnapshot['name'],
        //                           style: TextStyle(fontSize: 15),
        //                         ),
        //                       ],
        //                     ),
        //                     Row(
        //                       children: [
        //                         Text(
        //                           'E-Mail   :  ',
        //                           style: TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                         Text(
        //                           documentSnapshot['email'],
        //                           style: TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                     Row(
        //                       children: [
        //                         const Text(
        //                           'Mobile Number  : ',
        //                           style: TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                         Text(
        //                           documentSnapshot['mobileNo'],
        //                           style: const TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                     Row(
        //                       children: [
        //                         const Text(
        //                           'Registered On  : ',
        //                           style: TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                         Text(
        //                           documentSnapshot['registeredOn'],
        //                           style: const TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                     Row(
        //                       children: [
        //                         const Text(
        //                           'Mobile Number  : ',
        //                           style: TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                         Text(
        //                           documentSnapshot['updatedOn'],
        //                           style: const TextStyle(
        //                             fontSize: 10,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ],
        //                 ),
        //               );
        //             });
        //       }
        //       return CircularProgressIndicator();
        //     },
        //   ),
        );

    // Column(children: <Widget>[
    //   RaisedButton(child: Text('Insert'), onPressed: insertToFirebase),
    //   RaisedButton(
    //     onPressed: () {
    //       readFRomFirebase();
    //     },
    //     child: Text('read'),
    //   ),
    //   RaisedButton(
    //     onPressed: () {
    //       updateFirebase();
    //     },
    //     child: Text('update'),
    //   ),
    //   RaisedButton(
    //     onPressed: () {
    //       deleteFirebase();
    //     },
    //     child: Text('delete'),
    //   )
    // ]),
  }

  getTokenToSendNotification() async {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("tokenId").doc('RMX3092L1');

    documentReference.get().then((dataSnapshot) {
      data = dataSnapshot['tokenId'];
      print(data);
    });

    FirebaseMessaging.instance.subscribeToTopic('topic');
  }

  insertToFirebase() {
    referenceDatabase.child('Users').set({
      'name': 'ashok',
      'E-Mail': 'yuviashok.438@gmail.com',
      'Mobile Number': '8147220905',
      'Registered On': 'ekjfcbkvkdkvbsk',
      'Updated On': 'ake,hvb,hsbbsvbks'
    });
  }

  readFRomFirebase() {
    referenceDatabase
        .once()
        .then((DataSnapshot dataSnapshot) => print(dataSnapshot.value));
  }

  updateFirebase() {
    referenceDatabase.child('Users').set({'name': 'Ashok'});
  }

  deleteFirebase() {
    referenceDatabase.child('User').remove();
  }

  void sendFcmToAll(String title, String body, var fcmTokens) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$fcmKey'
    };
    var request = http.Request('POST', Uri.parse(fcmUrl));
    request.body =
        '''{"registration_ids":["efo2US3vTnCWGHcroLL8kJ:APA91bEt6d6ZjRLzMkr947LDW3omdaKgqt7l_eW6u1VLFSJ2lC7w3Jfs-Q7tzCsQST6yCMT2H87SmA3_rAfPBpe-F1mEpwMLFJYDi6BSGKb95hBXjK-URpo_afJQB4Fe0h5vHEsR0jUe","fcy43INiQMClOdTo8vPqkU:APA91bFyaq3IWnJesFfFqN7DoNHPFHVlNT3-8BtJewRVu1WkbJrFGKqFfBy4nK1K8uV5E0f9GpAAWDZ6OUtHByU4iDZGLB-MqsHbkbSQqYQNjaqRwP4U2IPFMvdQLUY0tcDw-kgDbOcQ"],"priority":"high","notification":{"title":"$title","body":"$body","sound": "default"}}''';

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    setState(() {
      response.statusCode == 200
          ? showdiallog('Notification sent Successfully')
          : showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Center(
                    child: Text(
                      'Send Failed',
                      style: TextStyle(color: Colors.red[500]),
                    ),
                  ),
                  actions: <Widget>[
                    Center(
                        child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'))),
                  ],
                );
              });
    });

    // if (response.statusCode == 200) {
    //   showdiallog('Notification sent successfully');
    //   print(await response.stream.bytesToString());
    // } else {
    //   print(response.reasonPhrase);
    // }
  }

  void sendFcmToParticularTopic(String title, String body) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$fcmKey'
    };
    var request = http.Request('POST', Uri.parse(fcmUrl));
    request.body =
        '''{"to":"/topics/group2","priority":"high","notification":{"title":"$title","body":"$body","sound": "default"}}''';

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    setState(() {
      response.statusCode == 200
          ? showdiallog('Notification sent Successfully')
          : showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Center(
                    child: Text(
                      'Send Failed',
                      style: TextStyle(color: Colors.red[500]),
                    ),
                  ),
                  actions: <Widget>[
                    Center(
                        child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'))),
                  ],
                );
              });
    });

    // if (response.statusCode == 200) {
    //   showdiallog('Notification sent successfully');
    //   print(await response.stream.bytesToString());
    // } else {
    //   print(response.reasonPhrase);
    // }
  }

  void sendFcm(String title, String body, String fcmToken) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$fcmKey'
    };
    var request = http.Request('POST', Uri.parse(fcmUrl));
    request.body =
        '''{"to":"$fcmToken","priority":"high","notification":{"title":"$title","body":"$body","sound": "default"}}''';

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    setState(() {
      response.statusCode == 200
          ? showdiallog('Notification sent Successfully')
          : showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: Center(
                    child: Text(
                      'Send Failed',
                      style: TextStyle(color: Colors.red[500]),
                    ),
                  ),
                  actions: <Widget>[
                    Center(
                        child: FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'))),
                  ],
                );
              });
    });

    // if (response.statusCode == 200) {
    //   showdiallog('Notification sent successfully');
    //   print(await response.stream.bytesToString());
    // } else {
    //   print(response.reasonPhrase);
    // }
  }

  getToken() async {
    var token = await FirebaseMessaging.instance.getToken();
    print(token);
  }

  Widget myWidget() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
