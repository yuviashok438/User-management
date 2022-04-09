import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'package:b/database_helper.dart';
import 'package:b/pages/login.dart';
import 'package:b/utils/Utility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key, this.user1}) : super(key: key);
  UserModel? user1;

  @override
  _UserProfileState createState() => _UserProfileState(user1);
}

class _UserProfileState extends State<UserProfile> {
  _UserProfileState(this.user1);
  final DataBaseHelper dBManager = DataBaseHelper();
  final referenceDatabase = FirebaseDatabase.instance.reference();
  UserCredential? userCredential;

  Utility utility = Utility();

  final LoginPage _loginPage = LoginPage();
  UserModel? user1;
  UserModel user = UserModel();
  String? mobileNo;
  String? updatedOn;
  String? name;
  String? email;
  String? registeredOn;
  String? lastLoggedOn;
  var _bytesImage;
  var _image2;
  String? loggedUser;
  var list;
  bool? choosedDatabase;
  String namefromfirebase = '';
  String emailfromfirebase = '';
  String mobileNofromfirebase = '';
  String updatedOnfromfirebase = '';
  String registeredOnfromfirebase = '';
  String imagefromfirebase = '';
  var image3;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name = user1!.name;
    email = user1!.email;
    mobileNo = user1!.mobileNo;
    registeredOn = user1!.registeredOn;
    updatedOn = user1!.updatedOn;
    lastLoggedOn = user1!.lastLogged;
    _image2 = getUint8List();
    getDataFromFirestore();
  }

  getUint8List() {
    var _image = Utility.dataFromBase64String(lastLoggedOn!);

    return _image;
  }

  getDataFromFirestore() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    loggedUser = sharedPreferences.getString('loggedUser');

    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("Users").doc(loggedUser);

    documentReference.get().then((dataSnapshot) {
      namefromfirebase = dataSnapshot['name'];
      emailfromfirebase = dataSnapshot['email'];
      mobileNofromfirebase = dataSnapshot['mobileNo'];
      updatedOnfromfirebase = dataSnapshot['updatedOn'];
      registeredOnfromfirebase = dataSnapshot['registeredOn'];
      imagefromfirebase = dataSnapshot['lastLogged'];
      image3 = Utility.dataFromBase64String(imagefromfirebase);
      var choosedDatabase1 = sharedPreferences.getBool('choosedDatabase');

      setState(() {
        choosedDatabase = choosedDatabase1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getImageFromFirebase();

    double width = MediaQuery.of(context).size.width;

    return choosedDatabase == null
        ? Scaffold(
            body: Center(
              child: Container(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("User Profile"),
              centerTitle: true,
            ),
            body: choosedDatabase!
                ? dataFromLocalDatabase(width)
                : dataFromFirebase(width));
  }

  Container dataFromLocalDatabase(double width) {
    return namefromfirebase == null
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: EdgeInsets.fromLTRB(60, 50, 50, 0),
            width: width,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _image2 == null
                        ? CircleAvatar(
                            radius: 100,
                            backgroundColor: Colors.red,
                          )
                        : CircleAvatar(
                            radius: 100,
                            backgroundImage: MemoryImage(_image2, scale: 0.5),
                          ),
                    Divider(
                      color: Colors.cyan,
                      height: 30,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'NAME :',
                          style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 2.0,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text('$name',
                              style: TextStyle(
                                color: Colors.amber,
                                letterSpacing: 2.0,
                                fontSize: 10,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'E-MAIL:',
                          style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 2.0,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text('$email',
                              style: TextStyle(
                                color: Colors.amber,
                                letterSpacing: 2.0,
                                fontSize: 10,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'MOBILE NO :',
                          style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 2.0,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text('$mobileNo',
                              style: TextStyle(
                                color: Colors.amber,
                                letterSpacing: 2.0,
                                fontSize: 10,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'REGISTERED ON:',
                          style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 2.0,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text('$registeredOn',
                              style: TextStyle(
                                color: Colors.amber,
                                letterSpacing: 2.0,
                                fontSize: 10,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'UPDATED ON :',
                          style: TextStyle(
                            color: Colors.grey,
                            letterSpacing: 2.0,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text('$updatedOn',
                              style: TextStyle(
                                color: Colors.amber,
                                letterSpacing: 2.0,
                                fontSize: 10,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Container dataFromFirebase(double width) {
    return namefromfirebase == null
        ? Container(
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Container(
            padding: EdgeInsets.fromLTRB(60, 50, 50, 0),
            width: width,
            child: Center(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      image3 == null
                          ? const CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.blue,
                            )
                          : CircleAvatar(
                              radius: 100,
                              backgroundImage: MemoryImage(image3, scale: 0.5),
                            ),
                      const Divider(
                        color: Colors.cyan,
                        height: 30,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: <Widget>[
                          const Text(
                            'NAME :',
                            style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 2.0,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              child: Text(namefromfirebase,
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    letterSpacing: 2.0,
                                    fontSize: 10,
                                  ))),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: <Widget>[
                          const Text(
                            'E-MAIL:',
                            style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 2.0,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(emailfromfirebase,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  letterSpacing: 2.0,
                                  fontSize: 10,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: <Widget>[
                          const Text(
                            'MOBILE NO :',
                            style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 2.0,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(mobileNofromfirebase,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  letterSpacing: 2.0,
                                  fontSize: 10,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: <Widget>[
                          const Text(
                            'REGISTERED ON:',
                            style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 2.0,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(registeredOnfromfirebase,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  letterSpacing: 2.0,
                                  fontSize: 10,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: <Widget>[
                          const Text(
                            'UPDATED ON :',
                            style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 2.0,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(updatedOnfromfirebase,
                                style: const TextStyle(
                                  color: Colors.amber,
                                  letterSpacing: 2.0,
                                  fontSize: 10,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  getImageFromFirebase() async {}
}
