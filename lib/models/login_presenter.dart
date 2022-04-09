import 'package:b/models/rest_data.dart';
import 'package:b/utils/Network_util.dart';

import '../database_helper.dart';

abstract class LoginCallBack {
  void onLoginSuccess(UserModel user);
  void onLoginError(String error);
}

class LoginResponse {
  LoginCallBack _view;
  LoginRequest loginRequest = new LoginRequest();
  LoginResponse(this._view);

  doLogin(String email, String password) async {
    loginRequest
        .getLogin(email, password)
        .then((user) => _view.onLoginSuccess(user))
        .catchError((onError) => _view.onLoginError(onError.toString()));
  }
}
