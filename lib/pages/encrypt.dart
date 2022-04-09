import 'package:flutter/material.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';

class Encrypt extends StatefulWidget {
  Encrypt({Key? key}) : super(key: key);

  @override
  _EncryptState createState() => _EncryptState();
}

class _EncryptState extends State<Encrypt> {
  final passwordControllee = TextEditingController();
  var key = "null";
  String? encryptedS, decrypt;
  var pass = "null";
  PlatformStringCryptor cryptor = PlatformStringCryptor();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('askcksa'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Center(
          child: Column(
            children: [
              TextFormField(
                controller: passwordControllee,
                decoration: InputDecoration(labelText: 'password'),
              ),
              RaisedButton(
                onPressed: () {
                  encrypted();
                },
                child: Text('encrypt'),
              ),
              SizedBox(
                height: 20.0,
              ),
              RaisedButton(
                onPressed: () {
                  decrypted();
                },
                child: Text('decrypt'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void encrypted() async {
    cryptor = PlatformStringCryptor();
    final salt = await cryptor.generateSalt();
    pass = passwordControllee.text;

    key = await cryptor.generateKeyFromPassword(pass, salt);

    encryptedS = await cryptor.encrypt(pass, key);
    print("Encypted text is :$encryptedS");
  }

  void decrypted() async {
    try {
      decrypt = await cryptor.decrypt(encryptedS, key);
      print("decrypted message is : $decrypt");
    } on MacMismatchException {}
  }
}
