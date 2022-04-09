import 'package:b/database_helper.dart';
import 'package:b/models/login_presenter.dart';
import 'package:b/pages/loading_page.dart';
import 'package:b/pages/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin
    implements LoginCallBack {
  String initialEmail = '';
  String initialPassword = '';

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DataBaseHelper dbmanager = new DataBaseHelper();
  String? loggedUser;
  String? loggedUserPassword;
  var _currentTime = new DateTime.now().toString();
  bool choosedDatabase = true;
  bool loading = false;
  bool isuserLoggedOut = true;

  BuildContext? _ctx;
  List<UserModel> userlist = [];
  LoginResponse? _response;

  final _formKey1 = GlobalKey<FormState>();

  _LoginPageState() {
    _response = new LoginResponse(this);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getisuserLoggedOut();
  }

  getisuserLoggedOut() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    isuserLoggedOut = sharedPreferences.getBool('isuserLoggedOut');
    print(isuserLoggedOut);

    if (isuserLoggedOut == true) {
      // initialEmail = sharedPreferences.getString('loggedUserFromHomePage');
      // initialPassword =
      //     sharedPreferences.getString('loggedUserFromHomePagePassword');
      // _usernameController.text = initialEmail;
      // _passwordController.text = initialPassword;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _submit() async {
    final form = _formKey1.currentState;
    if (form!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Choose database to continue'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            ChooseDatabase();
          },
        ),
      ));
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(text),
        duration: Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final forgotLabel = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.only(left: 0.0),
          child: const Text("Sign up",
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
        ),
        FlatButton(
          padding: EdgeInsets.all(0.0),
          child: const Text("Forgot password?",
              style: TextStyle(fontWeight: FontWeight.w300)),
          onPressed: () {
            Navigator.pushNamed(context, '/reset-password');
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("LOGIN"),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(40),
                child: Form(
                  key: _formKey1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 250.0,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        autofillHints: [AutofillHints.email],
                        keyboardType: TextInputType.emailAddress,
                        autofocus: false,
                        validator: (email) => !EmailValidator.validate(email)
                            ? 'Please Enter valid Email'
                            : null,
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          icon: Icon(Icons.mail),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      const SizedBox(height: 5.0),
                      TextFormField(
                        autofocus: false,
                        obscureText: true,
                        validator: (value) =>
                            value!.isEmpty ? "Password Cannot Be Empty" : null,
                        controller: _passwordController,
                        decoration: const InputDecoration(
                            labelText: "Password", icon: Icon(Icons.lock)),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                      Center(
                        child: RaisedButton(
                            child: const Text(
                              "Login",
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.blue,
                            onPressed: _submit),
                      ),
                      forgotLabel
                    ],
                  ),
                ),
              ),
            ));
      }),
    );
  }

  @override
  void onLoginError(String error) {
    // TODO: implement onLoginError
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Please enter valid credentilas ')));
    setState(() {
      loading = false;
    });
  }

  @override
  void onLoginSuccess(UserModel user) async {
    // TODO: implement onLoginSuccess
    if (user != null) {
      setState(() {
        loading = true;
      });
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      loggedUser = user.email;
      loggedUserPassword = user.password;
      _prefs.setString('loggedUser', loggedUser);
      _prefs.setString('loggedUserPassword', loggedUserPassword);

      Navigator.pushNamed(context, '/home');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Welcome : ${user.email}')));
    } else {
      _showSnackBar("please enter valid credentials ");
    }
  }

  ChooseDatabase() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text("Choose a database"),
            actions: [
              FlatButton(
                  onPressed: () async {
                    choosedDatabase = false;
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();

                    sharedPreferences.setBool(
                        'choosedDatabase', choosedDatabase);
                    final form = _formKey1.currentState;
                    if (form!.validate()) {
                      if (_response != null) {
                        setState(() {
                          form.save();
                          firebaseLogin();
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                  child: Text('Firebase ')),
              FlatButton(
                  onPressed: () async {
                    choosedDatabase = true;
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.setBool(
                        'choosedDatabase', choosedDatabase);
                    final form = _formKey1.currentState;
                    if (form!.validate()) {
                      if (_response != null) {
                        setState(() {
                          form.save();
                          _response!.doLogin(_usernameController.text,
                              _passwordController.text);
                          Navigator.pop(context);
                        });
                      }
                    }
                  },
                  child: Text('Sqflite '))
            ],
          );
        });
  }

  firebaseLogin() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _usernameController.text,
              password: _passwordController.text);

      var user = await userCredential.user!.email;
      if (user != null) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();

        _prefs.setString('loggedUser', user);
        _prefs.setString('loggedUserPassword', loggedUserPassword);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (e == 'user-not-found') {
        _showSnackBar('User not found ');
      } else if (e == 'wrong-password') {
        _showSnackBar('Please enter valid password');
      }
    }
  }
}
