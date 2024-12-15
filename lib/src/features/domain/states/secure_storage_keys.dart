import 'package:alex_k_test/src/config/constaints/keys.dart';

enum SecureStorageKeys {
  email,
  password
}

extension Values on SecureStorageKeys {
  String get key => switch(this){
    SecureStorageKeys.email => Keys.keysSecureStorage.email,
    SecureStorageKeys.password => Keys.keysSecureStorage.password,
  };


  }