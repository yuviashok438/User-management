import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  Database? _database;

  Future openDb() async {
    if (_database == null) {
      _database = await openDatabase(join(await getDatabasesPath(), "User4.db"),
          version: 1, onCreate: (Database db, int version) async {
        await db.execute(
            "CREATE TABLE User4(id INTEGER PRIMARY KEY autoincrement, name TEXT, email TEXT candidate key,password TEXT,mobileNo TEXT UNIQUE,registeredOn TEXT,updatedOn TEXT,lastLogged TEXT)");
      });
    }
  }

  Future<int> insertUser(UserModel user) async {
    await openDb();
    return await _database!.insert('User4', user.toMap());
  }

  Future<List<UserModel>> getUsersList() async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database!.query('User4');
    return List.generate(maps.length, (i) {
      return UserModel(
          id: maps[i]['id'],
          name: maps[i]['name'],
          email: maps[i]['email'],
          password: maps[i]['password'],
          mobileNo: maps[i]['mobileNo'],
          registeredOn: maps[i]['registeredOn'],
          updatedOn: maps[i]['updatedOn'],
          lastLogged: maps[i]['lastLogged']);
    });
  }

  Future<List<UserModel>> searchedUser(String keyword) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database!
        .query('User4', where: 'name LIKE ? ', whereArgs: ['%$keyword%']);
    return List.generate(maps.length, (index) {
      return UserModel(
        id: maps[index]['id'],
        name: maps[index]['name'],
        email: maps[index]['email'],
        password: maps[index]['password'],
        mobileNo: maps[index]['mobileNo'],
        registeredOn: maps[index]['registeredOn'],
        updatedOn: maps[index]['updatedOn'],
        lastLogged: maps[index]['lastLogged'],
      );
    });
  }

  Future<int> updateUser(UserModel user) async {
    await openDb();
    return await _database!
        .update('User4', user.toMap(), where: "id = ?", whereArgs: [user.id]);
  }

  Future<int> deleteUser(int id) async {
    await openDb();
    int ids =
        await _database!.delete('User4', where: "id = ?", whereArgs: [id]);
    return ids;
  }

  Future<UserModel> checkUserLogin(String email, String password) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database!.query('User4',
        columns: ['email', 'password'],
        where: "email = ? and password = ?",
        whereArgs: [email, password]);
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel> loginUserDetails(String email) async {
    await openDb();
    final List<Map<String, dynamic>> maps = await _database!.query('User4',
        columns: [
          'id',
          'email',
          'password',
          'name',
          'mobileNo',
          'registeredOn',
          'updatedOn',
          'lastLogged'
        ],
        where: "email = ?",
        whereArgs: [email]);
    return UserModel.fromMap(maps.first);
  }
}

class UserModel {
  String? tokenId;
  int? id;
  String? name;
  String? email;
  String? password;
  String? mobileNo;
  String? registeredOn;
  String? updatedOn;
  String? lastLogged;

  UserModel(
      {this.name,
      @required this.email,
      this.id,
      @required this.password,
      this.mobileNo,
      this.registeredOn,
      this.updatedOn,
      this.lastLogged,
      this.tokenId});
  Map<String, dynamic> toMap() {
    return {
      'tokenId': tokenId,
      'name': name,
      'email': email,
      'password': password,
      'mobileNo': mobileNo,
      'registeredOn': registeredOn,
      'updatedOn': updatedOn,
      'lastLogged': lastLogged,
    };
  }

  UserModel.fromMap(dynamic obj) {
    this.tokenId = obj['tokenId'];
    this.email = obj['email'];
    this.name = obj['name'];
    this.password = obj['password'];
    this.mobileNo = obj['mobileNo'];
    this.registeredOn = obj['registeredOn'];
    this.updatedOn = obj['updatedOn'];
    this.lastLogged = obj['lastLogged'];
  }
}
