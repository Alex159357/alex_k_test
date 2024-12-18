import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseAuth authClient;

  RemoteDataSourceImpl({
    required this.authClient,
  });

  @override
  Future<UserModel?> tryAuth(String email, String password) async {
    try {
      final userCredential = await _signInUser(email, password);
      return _mapUserCredentialToModel(userCredential);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        final newUserCredential = await _createUser(email, password);
        return _mapUserCredentialToModel(newUserCredential);
      }
      rethrow;
    }
  }

  @override
  Future<bool> tryLogOut() async {
    try {
      await authClient.signOut();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserCredential> _signInUser(String email, String password) async {
    return await authClient.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> _createUser(String email, String password) async {
    return await authClient.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  UserModel? _mapUserCredentialToModel(UserCredential? credential) {
    final user = credential?.user;
    if (user == null) return null;

    return UserModel(
      int.parse(user.uid.hashCode.toString()),
      user.email ?? "Unknown",
    );
  }
}
