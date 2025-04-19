import 'dart:convert';

import 'package:subscription_demo/helpers/all.dart';
import 'package:subscription_demo/models/authModel/auth_model.dart';

extension SharedPreferencesX on SharedPreferences {
  String? get getToken {
    return getString(KeyName.token);
  }

  set setToken(String? value) {
    if (value == null) {
      remove(KeyName.token);
    } else {
      setString(KeyName.token, value);
    }
  }

  /// <<< --------- To Save Login Data --------- >>>
  set setLoginData(AuthData loginResponse) {
    final allData = jsonEncode(loginResponse);
    setString('loginData', allData);

    setString('UserId', loginResponse.id ?? '');
    setString('token', loginResponse.token ?? '');
  }

  set nullLoginData(AuthData? loginResponse) {
    remove('loginData');
  }
}
