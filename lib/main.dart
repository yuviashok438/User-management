import 'dart:async';
import 'dart:convert';

import 'package:b/database_helper.dart';
import 'package:b/onesignal_example.dart';
import 'package:b/pages/encrypt.dart';
import 'package:b/pages/forgot_page.dart';
import 'package:b/pages/loading_page.dart';
import 'package:b/pages/login.dart';
import 'package:b/pages/my_home_page.dart';
import 'package:b/pages/navigation_drawer.dart';
import 'package:b/pages/registerPage.dart';
import 'package:b/pages/search_page.dart';
import 'package:b/pages/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final navigatorKey = GlobalKey<NavigatorState>();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    importance: Importance.high, playSound: true);

FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future _firebasemessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message shows up : $message');
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    showGeneralDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(navigatorKey.currentContext!)
            .modalBarrierDismissLabel,
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
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebasemessagingBackgroundHandler);

  await localNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => LoginPage(),
      '/home': (context) => MyHomePage(),
      '/register': (context) => RegiserPage(),
      '/encrypt': (context) => Encrypt(),
      '/edit': (context) => EditPage(),
      '/profile': (context) => UserProfile(),
      '/reset-password': (context) => ForgotPage(),
      '/search': (context) => SearchPage(),
      'loading': (context) => LoadingPage(),
      '/onesignal': (context) => MyAppOne(),
    },
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class EditPage extends StatefulWidget {
  EditPage({
    Key? key,
  }) : super(key: key);
  final _formKey1 = GlobalKey<FormState>();

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  _EditPageState();
  final DataBaseHelper dbmanager = new DataBaseHelper();

  var currentTime;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileNoController = TextEditingController();

  var deletemail;

  final josKeys1 = new GlobalKey<FormState>();
  UserModel? user;
  List<UserModel> userlist = [];
  bool order = false;
  var updatedOn = new DateTime.now().toString();
  int? updateIndex;
  String? password;
  String? image;
  bool choosedDatabase = false;
  List<UserModel> userslist = [];
  String myOnesignalAppId = 'e97a4971-1e60-455f-ac49-87c2a78fde2a';
  bool _requireConsent = true;

  final NavigationDrawerWidget navigationDrawerWidget =
      new NavigationDrawerWidget();

  getcurrentTime() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    currentTime = sharedPreferences.getString('currentTime');
    image = sharedPreferences.getString('lastLogged');
    password = sharedPreferences.getString('password');
  }

  getChoosedDatabase() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      choosedDatabase = sharedPreferences.getBool('choosedDatabase');
    });
  }

  @override
  void initState() {
    super.initState();
    getcurrentTime();
    getChoosedDatabase();
  }

  showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Ok'))
            ],
          );
        });
  }

  showdialog() {
    showGeneralDialog(
        context: navigatorKey.currentContext!,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(navigatorKey.currentContext!)
            .modalBarrierDismissLabel,
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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: NavigationDrawerWidget(),
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView(
          children: <Widget>[
            Form(
              key: josKeys1,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      decoration: new InputDecoration(labelText: 'Name'),
                      controller: _nameController,
                      validator: (val) =>
                          val!.isNotEmpty ? null : 'Name Should Not Be empty',
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      readOnly: true,
                      decoration: new InputDecoration(labelText: 'E -mail'),
                      controller: _emailController,
                      validator: (val) =>
                          val!.isNotEmpty ? null : 'E-Mail Should Not Be empty',
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      autofocus: false,
                      maxLength: 10,
                      decoration:
                          new InputDecoration(labelText: 'Mobile Number'),
                      controller: _mobileNoController,
                      validator: (val) => val!.length < 10
                          ? 'Mobile Number Should Not Be empty'
                          : null,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    RaisedButton(
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                      onPressed: () {
                        showNotification();
                      },
                      child: Container(
                        width: width * 09,
                        child: Text(
                          'Notication',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blueAccent,
                      child: Container(
                          width: width * 0.9,
                          child: Text(
                            'Submit',
                            textAlign: TextAlign.center,
                          )),
                      onPressed: () {
                        choosedDatabase
                            ? _submitUser(context)
                            : updateFirestoreData();
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RaisedButton(
                      onPressed: () {
                        _nameController.clear();
                        _emailController.clear();
                        _mobileNoController.clear();
                      },
                      textColor: Colors.white,
                      color: Colors.blueAccent,
                      child: Container(
                        width: width * 0.9,
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        actions: [
                                          FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  order = true;
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Text('Newest First')),
                                          FlatButton(
                                              onPressed: () {
                                                setState(() {
                                                  order = false;
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: Text('OLdest First')),
                                          FlatButton(
                                              onPressed: () async {},
                                              child:
                                                  Text('Location permission')),
                                        ],
                                      );
                                    });
                              },
                              icon: Icon(
                                Icons.sort,
                                color: Colors.blue,
                              )),
                        ],
                      ),
                    ),
                    choosedDatabase
                        ? getDataFromLocalDatabase(width)
                        : getDataFromFirebase()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView getDataFromLocalDatabase(double width) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: dbmanager.getUsersList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            userlist = snapshot.data as List<UserModel>;
            return SingleChildScrollView(
              child: ListView.builder(
                reverse: order,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: userlist == null ? 0 : userlist.length,
                itemBuilder: (BuildContext context, int index) {
                  UserModel st = userlist[index];
                  return SingleChildScrollView(
                    child: Card(
                      child: SingleChildScrollView(
                        child: Row(
                          children: <Widget>[
                            SingleChildScrollView(
                              child: Container(
                                width: width * 0.6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Name: ${st.name}',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Text(
                                      'E-mail: ${st.email}',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      'Mobile Number: ${st.mobileNo}',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      'Registered on: ${st.registeredOn}',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      'Updated On: ${st.updatedOn}',
                                      style: TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _nameController.text = st.name!;
                                _emailController.text = st.email!;
                                _mobileNoController.text = st.mobileNo!;
                                user = st;
                                updateIndex = index;

                                updatedOn = new DateTime.now().toString();
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                return showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Text('Do you want to delete'),
                                        actions: [
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('NO')),
                                          FlatButton(
                                              onPressed: () async {
                                                int i = await dbmanager
                                                    .deleteUser(st.id!);

                                                setState(() {
                                                  userlist.removeAt(index);
                                                  if (i != null) {
                                                    Navigator.pop(context);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'deletion failed')));
                                                  }
                                                });
                                              },
                                              child: Text('YES')),
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return new CircularProgressIndicator();
        },
      ),
    );
  }

  void _submitUser(BuildContext context) {
    if (josKeys1.currentState!.validate()) {
      if (user == null) {
        UserModel st = UserModel(
            name: _nameController.text,
            email: _emailController.text,
            password: password,
            mobileNo: _mobileNoController.text,
            updatedOn: updatedOn,
            lastLogged: image,
            registeredOn: currentTime);
        setState(() {});
        dbmanager.insertUser(st).then((id) => {
              _nameController.clear(),
              _emailController.clear(),
              _mobileNoController.clear(),
              print('User Added to Db ${id}')
            });
      } else {
        user!.name = _nameController.text;
        user!.email = _emailController.text;
        user!.mobileNo = _mobileNoController.text;
        user!.updatedOn = updatedOn;

        dbmanager.updateUser(user!).then((id) => {
              setState(() {
                userlist[updateIndex!].name = _nameController.text;
                userlist[updateIndex!].email = _emailController.text;
                userlist[updateIndex!].mobileNo = _mobileNoController.text;
                userlist[updateIndex!].updatedOn = updatedOn;
              }),
              _nameController.clear(),
              _emailController.clear(),
              _mobileNoController.clear(),
              user = null
            });
      }
    }
  }

  updateFirestoreData() {
    var updatedOn1 = new DateTime.now().toString();

    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('Users')
        .doc(_emailController.text);

    documentReference.update({
      'name': _nameController.text,
      'mobileNo': _mobileNoController.text,
      'updatedOn': updatedOn1
    });
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _mobileNoController.clear();
    });
  }

  Map<String, dynamic> firebaseDatabase(UserModel user) {
    Map<String, dynamic> list = user.toMap();
    return list;
  }

  getDataFromFirebase() {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: ListView.builder(
                  shrinkWrap: true,
                  reverse: order,
                  physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot documentSnapshot =
                        snapshot.data!.docs[index];
                    resizeToAvoidBottomInset:
                    true;

                    print(userlist);
                    return Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                'Name  :   ',
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                documentSnapshot['name'],
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'E-Mail   :  ',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                documentSnapshot['email'],
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Mobile Number  : ',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                documentSnapshot['mobileNo'],
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Registered On  : ',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                documentSnapshot['registeredOn'],
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Updated On  : ',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                documentSnapshot['updatedOn'],
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _nameController.text =
                                      documentSnapshot['name'];
                                  _emailController.text =
                                      documentSnapshot['email'];
                                  _mobileNoController.text =
                                      documentSnapshot['mobileNo'];
                                },
                                icon: Icon(Icons.edit),
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 200,
                              ),
                              IconButton(
                                  onPressed: () async {
                                    return showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content:
                                                Text('Do you want to delete'),
                                            actions: [
                                              FlatButton(
                                                  onPressed: () {
                                                    deletemail =
                                                        documentSnapshot[
                                                            'email'];
                                                    DocumentReference
                                                        documentReference =
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("Users")
                                                            .doc(deletemail);

                                                    documentReference.delete();
                                                    Navigator.pop(context);

                                                    setState(() {});
                                                  },
                                                  child: Text('Yes')),
                                              FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      Navigator.pop(context);
                                                    });
                                                  },
                                                  child: Text('NO'))
                                            ],
                                          );
                                        });
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ))
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

showNotification() {
  localNotificationsPlugin.show(
      0,
      'Testing',
      'Notification Testing ',
      NotificationDetails(
          android: AndroidNotificationDetails(channel.id, channel.name,
              importance: Importance.high,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher')));
}
