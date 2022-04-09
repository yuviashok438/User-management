import 'dart:convert';

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:b/database_helper.dart';
import 'package:b/main.dart';
import 'package:b/pages/loading_page.dart';
import 'package:b/pages/login.dart';
import 'package:b/pages/profile_picture.dart';
import 'package:b/utils/Utility.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class RegiserPage extends StatefulWidget {
  RegiserPage({Key? key}) : super(key: key);

  var currentTime = new DateTime.now().toString();

  @override
  _RegiserPageState createState() => _RegiserPageState();
}

class _RegiserPageState extends State<RegiserPage> {
  final DataBaseHelper dbmanager = new DataBaseHelper();
  var username;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileNoController = TextEditingController();
  final _confirmPasswordConroller = TextEditingController();
  PlatformStringCryptor cryptor = PlatformStringCryptor();
  bool loading = false;
  String? base64Image;
  XFile? profilePicture2;
  var pass;
  var key;
  bool choosedDatabase = false;
  final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
  final firebase = FirebaseDatabase.instance.reference();

  String encryptedS = "encryptedS", decryptedS = "decryptedS";

  Future<String> encrypted(String password) async {
    cryptor = PlatformStringCryptor();
    final salt = await cryptor.generateSalt();
    pass = password;

    key = await cryptor.generateKeyFromPassword(pass, salt);

    encryptedS = await cryptor.encrypt(pass, key);
    print("Encypted text is :$encryptedS");
    return encryptedS;
  }

  Future<String> decrypted(String passDecrypted) async {
    try {
      decryptedS = await cryptor.decrypt(passDecrypted, key);
      print("decrypted message is : $decryptedS");
    } on MacMismatchException {}
    return decryptedS;
  }

  var currentTime = new DateTime.now().toString();

  final _formKey2 = GlobalKey<FormState>();

  UserModel? user;

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(text),
        duration: Duration(seconds: 2)));
  }

  @override
  void initState() {
    super.initState();
    getchoosedDatabase();
  }

  getchoosedDatabase() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    choosedDatabase = sharedPreferences.getBool('choosedDatabase');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return loading
        ? LoadingPage()
        : Scaffold(
            appBar: AppBar(
              title: Text('Register'),
            ),
            body: ListView(
              children: <Widget>[
                Form(
                  key: _formKey2,
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: _showSelectImage,
                          child: Container(
                            child: profilePicture2 == null
                                ? CircleAvatar(
                                    radius: 70,
                                    backgroundColor: Colors.blue,
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: 100,
                                    backgroundImage:
                                        FileImage(File(profilePicture2!.path)),
                                  ),
                          ),
                        ),
                        TextFormField(
                          decoration: new InputDecoration(
                              labelText: 'Name', icon: Icon(Icons.person)),
                          controller: _nameController,
                          validator: (val) => val!.isNotEmpty
                              ? null
                              : 'Name Cannot Not Be Empty',
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Email', icon: Icon(Icons.mail)),
                          controller: _emailController,
                          validator: (email) => EmailValidator.validate(email)
                              ? null
                              : 'Please Enter Valid Email',
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Password', icon: Icon(Icons.lock)),
                          controller: _passwordController,
                          obscureText: true,
                          validator: (val) => val!.length > 3
                              ? null
                              : 'Password Cannot Be Empty',
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          decoration: new InputDecoration(
                              labelText: 'Confirm Password',
                              icon: Icon(Icons.lock)),
                          controller: _confirmPasswordConroller,
                          obscureText: true,
                          validator: (val) => val!.length > 3
                              ? null
                              : 'Please Re-Enter Your Password',
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: new InputDecoration(
                              labelText: 'Mobile Number',
                              icon: Icon(Icons.phone)),
                          controller: _mobileNoController,
                          maxLength: 10,
                          validator: (val) => val!.length < 10
                              ? ' Please Enter valid phone number '
                              : null,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        RaisedButton(
                          textColor: Colors.white,
                          color: Colors.blue,
                          child: Container(
                              child: Text(
                            'Login',
                            textAlign: TextAlign.center,
                          )),
                          onPressed: () {
                            chooseDatabase();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  void saveInLocal(BuildContext context) async {
    if (_formKey2.currentState!.validate()) {
      String password = _passwordController.text;
      var pass = await encrypted(password);

      var passDecrypted = await decrypted(pass);

      if (_passwordController.text == _confirmPasswordConroller.text) {
        UserModel st = new UserModel(
            name: _nameController.text,
            email: _emailController.text,
            password: passDecrypted,
            mobileNo: _mobileNoController.text,
            registeredOn: currentTime,
            lastLogged: base64Image);
        if (base64Image != null) {
          dbmanager.insertUser(st).then((id) => {
                _nameController.clear(),
                _emailController.clear(),
                _mobileNoController.clear(),
                print('User Added to Db ${id}')
              });

          if (st != null) {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();

            sharedPreferences.setString('currentTime', currentTime);
            sharedPreferences.setString('lastLogged', base64Image);
            sharedPreferences.setString('password', passDecrypted);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content:
                  Text('Registration Succesfull .. Please Continue To Login'),
              duration: Duration(seconds: 5),
            ));
            Navigator.pushReplacementNamed(context, '/');
          } else {
            ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
              backgroundColor: Colors.red,
              content: Text('user creation failed'),
              actions: [],
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text('Please add profile photo to continue'),
            duration: Duration(seconds: 1),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.red, content: Text('Password must match')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('please enter all the details properly')));
    }
  }

  void _showSelectImage() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Add a photo"),
            actions: [
              FlatButton(
                onPressed: () async {
                  var Imgfile =
                      await ImagePicker().pickImage(source: ImageSource.camera);

                  if (Imgfile != null) {
                    Uint8List _bytesImage = await Imgfile.readAsBytes();
                    base64Image = base64Encode(_bytesImage);

                    setState(() {
                      profilePicture2 = Imgfile;
                    });
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Profile Photo added succesfully ')));
                  } else {
                    _showSnackBar('Failed to add profile photo');
                  }
                },
                child: Text('Camera'),
              ),
              FlatButton(
                onPressed: () async {
                  XFile? imgFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (imgFile != null) {
                    Uint8List _bytesImage = await imgFile.readAsBytes();
                    base64Image = base64Encode(_bytesImage);

                    setState(() {
                      profilePicture2 = imgFile;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Profile Photo added succesfully ')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to Add Your photo ')));
                  }
                },
                child: Text('Galllery'),
              )
            ],
          );
        });
  }

  saveInCloud() async {
    if (_formKey2.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordConroller.text) {
        if (base64Image != null) {
          UserModel st = new UserModel(
              tokenId: FirebaseAuth.instance.currentUser!.uid,
              name: _nameController.text,
              email: _emailController.text,
              password: 'Encrypted',
              mobileNo: _mobileNoController.text,
              registeredOn: currentTime,
              lastLogged: base64Image,
              updatedOn: 'Not Yet Updated');
          Map<String, dynamic> maps = firebaseDatabase(st);
          print(maps);
          try {
            DocumentReference documentReference = FirebaseFirestore.instance
                .collection('Users')
                .doc(_emailController.text);

            UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text);

            documentReference.set(maps).whenComplete(() {
              CircularProgressIndicator();
              Navigator.pop(context);
              return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.green,
                  content:
                      Text('Registered successfully .. continue to login')));
            });
          } catch (error) {
            print(error);
          }
        } else {
          _showSnackBar('Please add profile photo to continue');
        }
      } else {
        _showSnackBar('Password Must match');
      }
    } else {
      _showSnackBar('Enter all the details properly');
    }
  }

  chooseDatabase() {
    if (_formKey2.currentState!.validate()) {
      if (_passwordController.text == _confirmPasswordConroller.text) {
        if (base64Image != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Choose a database to continue"),
            action: SnackBarAction(
              label: 'Ok',
              onPressed: () {
                chooseDatabaseDialog();
              },
            ),
          ));
        } else {
          _showSnackBar('Please add profile photo to continue');
        }
      } else {
        _showSnackBar('Password Must match');
      }
    } else {
      _showSnackBar('Enter all the details properly');
    }
  }

  chooseDatabaseDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Choose a database'),
            actions: [
              FlatButton(
                  onPressed: () async {
                    choosedDatabase = false;
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();

                    sharedPreferences.setBool(
                        'choosedDatabase', choosedDatabase);
                    saveInCloud();
                    Navigator.pop(context);
                  },
                  child: Text('Firebse')),
              FlatButton(
                  onPressed: () async {
                    choosedDatabase = true;
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();

                    sharedPreferences.setBool(
                        'choosedDatabase', choosedDatabase);
                    saveInLocal(context);
                    Navigator.pop(context);
                  },
                  child: Text('Sqflite'))
            ],
          );
        });
  }

  RegisterUserInFirebase() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for this email.');
      }
    } catch (e) {
      print(e);
    }
  }
}

Map<String, dynamic> firebaseDatabase(UserModel user) {
  Map<String, dynamic> list = user.toMap();
  return list;
}
