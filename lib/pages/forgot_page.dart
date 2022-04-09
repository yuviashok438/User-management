import 'dart:convert';

import 'package:b/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPage extends StatefulWidget {
  ForgotPage({Key? key}) : super(key: key);

  @override
  _ForgotPageState createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  TextEditingController _emailController = TextEditingController();
  final DataBaseHelper dbmanager = new DataBaseHelper();

  final _formKey1 = GlobalKey<FormState>();
  String? email;
  String? name;
  String? subject;
  String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Center(
        child: Form(
          key: _formKey1,
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 200,
                ),
                SizedBox(
                  width: 50,
                ),
                TextFormField(
                  scrollPadding: EdgeInsets.fromLTRB(50, 50, 50, 0),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter Email' : null,
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter Your Email',
                  ),
                ),
                RaisedButton(
                  color: Colors.blue,
                  onPressed: () {
                    getUser();
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getUser() async {
    final form = _formKey1.currentState;
    if (form!.validate()) {
      String email = _emailController.text;
      UserModel user = await dbmanager.loginUserDetails(email);
      String? email1 = user.email!;
      name = user.name!;
      subject = 'Your Password';
      message = ' Hi there ...here is your password ${user.password}';

      if (email1 == email) {
        print(email1);
        final serviceId = 'service_xv8r1vk';
        final templateId = 'template_22rww8k';
        final userId = 'user_EN8TQSjumNiPYqiqoCWCh';

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final response = await http.post(url,
            headers: {
              'origin': 'http://localhost',
              'Content-Type': 'application/json'
            },
            body: json.encode({
              'service_id': serviceId,
              'template_id': templateId,
              'user_id': userId,
              'template_params': {
                'user_name': name,
                'user_email': email,
                'user_subject': subject,
                'user_message': message,
              }
            }));
        print(response.body);
        if (response.body != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.green,
              content: Text('Email sent successfully')));
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Cannot send email')));
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No User Found')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid email')));
    }
  }
}
