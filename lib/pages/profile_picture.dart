import 'package:b/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StreamBuilderpage extends StatefulWidget {
  StreamBuilderpage({Key? key}) : super(key: key);

  @override
  _StreamBuilderpageState createState() => _StreamBuilderpageState();
}

class _StreamBuilderpageState extends State<StreamBuilderpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('csZcs'),
      ),
      body: Container(
        child: Center(
          child: CircleAvatar(),
        ),
      ),
    );
  }
}
