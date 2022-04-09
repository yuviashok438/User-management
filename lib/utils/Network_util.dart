import '../database_helper.dart';

class LoginRequest {
  final DataBaseHelper dbmanager = new DataBaseHelper();

  Future<UserModel> getLogin(String email, String password) async {
    UserModel result = await dbmanager.checkUserLogin(email, password);
    return result;
  }
}
