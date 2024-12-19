import 'package:alex_k_test/src/features/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserMapper {
  static UserModel? fromCredential(UserCredential? credential) {
    final user = credential?.user;
    if (user == null) return null;

    return UserModel(
      int.parse(user.uid.hashCode.toString()),
      user.email ?? "Unknown",
    );
  }

  static UserModel? fromFirebaseUser(User? user) {
    if (user == null) return null;

    return UserModel(
      int.parse(user.uid.hashCode.toString()),
      user.email ?? "Unknown",
    );
  }
}
