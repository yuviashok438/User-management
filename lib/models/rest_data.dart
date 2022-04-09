import 'package:b/database_helper.dart';
import 'package:b/utils/Network_util.dart';

class RestData {
  static final BASE_URL = "";
  static final LOGIN_URL = BASE_URL + "/";

  Future<UserModel> login(String email, String password) {
    return new Future.value(new UserModel(email: email, password: password));
  }
}
