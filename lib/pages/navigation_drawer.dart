import 'package:b/database_helper.dart';
import 'package:b/main.dart';
import 'package:b/pages/loading_page.dart';
import 'package:b/pages/login.dart';
import 'package:b/pages/search_page.dart';
import 'package:b/pages/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:b/main.dart';
import 'package:b/pages/my_home_page.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationDrawerWidget extends StatefulWidget {
  NavigationDrawerWidget({Key? key}) : super(key: key);

  @override
  _NavigationDrawerWidgetState createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = EdgeInsets.symmetric(horizontal: 20.0);
  final DataBaseHelper dBManager = DataBaseHelper();
  final isCollaspsed = false;
  bool loading = false;
  bool isuserLoggedOut = true;
  UserModel user = UserModel();

  bool choosedDatabase = false;
  @override
  void initState() {
    super.initState();
    getChoosedDatabase();
  }

  getChoosedDatabase() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    choosedDatabase = sharedPreferences.getBool('choosedDatabase');
  }

  logOutAsPerLocalDatabase() async {
    isuserLoggedOut = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('isuserLoggedOut', isuserLoggedOut);
    Navigator.pop(context);

    Navigator.pushReplacementNamed(context, '/');
    Navigator.pop(context);
  }

  logOutAsPerCloudDatabase() async {
    isuserLoggedOut = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('isuserLoggedOut', isuserLoggedOut);
    Navigator.pop(context);

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: isCollaspsed ? MediaQuery.of(context).size.width * 02 : null,
        child: Material(
            color: Colors.blue,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Container(
                  padding: padding,
                  child: Column(
                    children: [
                      buidSearchField(),
                      SizedBox(
                        height: 20,
                      ),
                      buildHeader(
                          icon: Icons.person,
                          text: 'Profile',
                          onClicked: () {
                            setState(() {
                              loading = true;
                            });
                            selectedItem(context, 5);
                          }),
                      SizedBox(
                        height: 25,
                      ),
                      buildMenuItem(
                          text: 'Home',
                          icon: Icons.home,
                          onClicked: () => selectedItem(context, 0)),
                      SizedBox(
                        height: 20.0,
                      ),
                      buildMenuItem(
                          text: 'Users',
                          icon: Icons.people,
                          onClicked: () => selectedItem(context, 1)),
                      SizedBox(
                        height: 20,
                      ),
                      buildMenuItem(
                          text: 'Update',
                          icon: Icons.edit,
                          onClicked: () => selectedItem(context, 2)),
                      SizedBox(
                        height: 20,
                      ),
                      // buildMenuItem(
                      //     text: 'Favorite',
                      //     icon: Icons.favorite,
                      //     onClicked: () => selectedItem(context, 3)),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50.0,
                      ),
                      Divider(color: Colors.white60),
                      SizedBox(
                        height: 20,
                      ),
                      buildMenuItem(
                          text: 'Logout',
                          icon: Icons.logout,
                          onClicked: () => selectedItem(context, 4)),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget buildHeader({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) {
    final color = Colors.white;

    return ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          text,
          style: TextStyle(color: color),
        ),
        onTap: onClicked);
  }

  Widget buidSearchField() {
    return TextField(
      style: TextStyle(color: Colors.white70),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          hintText: 'Search',
          hintStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.7))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.7)))),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    final color = Colors.white;
    return ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(
          text,
          style: TextStyle(color: color),
        ),
        onTap: onClicked);
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/edit');
        break;
      case 4:
        setState(() async {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Text('Are You sure !!   You Want to Logout?'),
                  actions: [
                    FlatButton(
                        onPressed: () async {
                          choosedDatabase
                              ? logoutFromLocalDatabase(context)
                              : logoutFromFirebase(context);
                        },
                        child: Text('YES')),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('NO'))
                  ],
                );
              });
        });
        break;
      case 5:
        choosedDatabase ? doSomething() : doSomethingFirebase();
        break;
    }
  }

  doSomething() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String loggedUser = sharedPreferences.getString('loggedUser');

    try {
      var user = await dBManager.loginUserDetails(loggedUser);
      print(user.email);
      String? name = user.name;
      String? email = user.email;
      String? mobileNo = user.mobileNo;
      String? registeredOn = user.registeredOn;
      String? updatedOn = user.updatedOn;
      print(name);
      print(email);
      print(mobileNo);
      print(registeredOn);
      print(updatedOn);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => UserProfile(user1: user)));
    } catch (e) {
      print('User not found in local database');
    }
  }

  doSomethingFirebase() async {
    UserModel user2 = UserModel(
        email: 'yuviashok.438@gmail.com',
        password: 'Ashok.s12',
        name: 'savsdv',
        mobileNo: '225515555',
        registeredOn: 'ACASCAScsV',
        updatedOn: 'asvsADVAd',
        lastLogged: 'wwwwwwww');
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => UserProfile(user1: user2)));
  }

  logoutFromLocalDatabase(BuildContext context) async {
    isuserLoggedOut = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('isuserLoggedOut', isuserLoggedOut);

    Navigator.pop(context);

    Navigator.pushReplacementNamed(context, '/');

    Navigator.pop(context);
  }

  logoutFromFirebase(BuildContext context) async {
    isuserLoggedOut = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('isuserLoggedOut', isuserLoggedOut);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/');
  }
}
