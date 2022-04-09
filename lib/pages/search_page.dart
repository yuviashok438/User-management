import 'package:b/database_helper.dart';
import 'package:b/pages/navigation_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String keyword = '';
  final DataBaseHelper dbmanager = new DataBaseHelper();
  List<UserModel> list = [];
  bool order = true;
  int? sortColumnIndex;
  bool isAscending = false;
  bool? choosedDatabase;
  String? deletemail;

  @override
  void initState() {
    super.initState();
    getchoosedDatabase();
  }

  getchoosedDatabase() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      choosedDatabase = sharedPreferences.getBool('choosedDatabase');
    });
  }

  getDataFromFirebase() {
    return SingleChildScrollView(
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .orderBy('name')
            .startAt([keyword]).endAt([keyword + '\uf8ff']).snapshots(),
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
                                  onPressed: () async {
                                    return showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content:
                                                Text('Do you want to delete'),
                                            actions: [
                                              Center(
                                                child: FlatButton(
                                                    onPressed: () {
                                                      deletemail =
                                                          documentSnapshot[
                                                              'email'];
                                                      DocumentReference
                                                          documentReference =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "Users")
                                                              .doc(deletemail);

                                                      documentReference
                                                          .delete();
                                                      Navigator.pop(context);

                                                      setState(() {});
                                                    },
                                                    child: Text('Yes')),
                                              ),
                                              Center(
                                                child: FlatButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: Text('NO')),
                                              )
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

  @override
  Widget build(BuildContext context) {
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
            drawer: NavigationDrawerWidget(),
            appBar: AppBar(
              title: Text('Search Users'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50.0,
                      ),
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Search',
                            icon: Icon(Icons.search)),
                        onChanged: (value) {
                          keyword = value;
                          setState(() {});
                        },
                      ),
                      Container(
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Center(
                                          child: AlertDialog(
                                            actions: [
                                              Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    FlatButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            order = true;
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                        child: Text(
                                                            'Newest First')),
                                                    FlatButton(
                                                        padding: EdgeInsets
                                                            .symmetric(),
                                                        onPressed: () {
                                                          setState(() {
                                                            order = false;
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                        child: Text(
                                                            'Oldest First '))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                icon: const Icon(
                                  Icons.sort,
                                  color: Colors.blue,
                                )),
                          ],
                        ),
                      ),
                      choosedDatabase!
                          ? getDataFromLocalDatabase(width)
                          : getDataFromFirebase()
                    ],
                  ),
                ),
              ),
            ));
  }

  SingleChildScrollView getDataFromLocalDatabase(double width) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: dbmanager.searchedUser(keyword),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            list = snapshot.data as List<UserModel>;
            return SingleChildScrollView(
              child: ListView.builder(
                reverse: order,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: list == null ? 0 : list.length,
                itemBuilder: (BuildContext context, int index) {
                  UserModel st = list[index];
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
                                                  list.removeAt(index);
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
}
