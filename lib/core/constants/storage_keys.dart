class StorageKeys {
  StorageKeys._();

  static const String appState = 'app_state';
  static const String loginStatus = 'login_status';
  static const String deviceId = 'device_id';
  static const String token = 'token';
  static const String userId = 'user_id';
  static const String email = 'email';
  static const String username = 'username';
  static const String authType = 'auth_type';
}

class AppState {
  AppState._();

  static const String unregistered = 'unregistered';
  static const String registered = 'registered';
}

class AuthType {
  AuthType._();

  static const String local = 'local';
  static const String online = 'online';
}

class LoginStatus {
  LoginStatus._();

  static const String loggedOut = 'loggedOut';
  static const String loggedIn = 'loggedIn';
}
