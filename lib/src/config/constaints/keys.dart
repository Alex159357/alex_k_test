import 'package:flutter/foundation.dart';

class Keys {
  static const KeysSecureStorage keysSecureStorage = KeysSecureStorage();
}

@immutable
class KeysSecureStorage {
  final String email;
  final String password;

  const KeysSecureStorage({this.email = "email", this.password = "password"});
}
