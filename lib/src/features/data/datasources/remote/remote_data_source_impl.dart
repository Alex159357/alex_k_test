import 'package:alex_k_test/src/core/exceptions/auth_exception.dart';
import 'package:alex_k_test/src/core/utils/mappers/user_mapper.dart';
import 'package:alex_k_test/src/features/data/datasources/remote/remote_data_source.dart';
import 'package:alex_k_test/src/features/data/models/map_pin_model.dart';
import 'package:alex_k_test/src/features/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class RemoteDataSourceImpl implements RemoteDataSource {
  final FirebaseAuth _authClient;
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  static const String _mapPinsCollection = 'map_pins';

  RemoteDataSourceImpl({
    required FirebaseAuth authClient,
    required FirebaseFirestore firestore,
  })  : _authClient = authClient,
        _firestore = firestore;

  @override
  Future<List<MapPinModel>> fetchMapPins() async {
    try {
      // Get current user ID
      final userId = _authClient.currentUser?.uid;
      if (userId == null) {
        _logger.w('Attempted to fetch map pins without authentication');
        return [];
      }

      // Query Firestore for all pins belonging to the current user
      final querySnapshot = await _firestore
          .collection(_mapPinsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      // Convert documents to MapPinModel objects
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Add the Firestore document ID to the data
        data['firebaseId'] = doc.id;
        return MapPinModel.fromJson(data);
      }).toList();
    } on FirebaseException catch (e, stackTrace) {
      _logger.e(
        'Firebase error while fetching map pins',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    } catch (e, stackTrace) {
      _logger.e(
        'Unexpected error while fetching map pins',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<UserModel?> tryAuth(String email, String password) async {
    try {
      final userCredential = await _signInUser(email, password);
      return UserMapper.fromCredential(userCredential);
    } on FirebaseAuthException catch (e, stackTrace) {
      _logger.w(
        'Firebase auth exception during sign in',
        error: e,
        stackTrace: stackTrace,
      );

      if (e.code == 'user-not-found') {
        try {
          final newUserCredential = await _createUser(email, password);
          return UserMapper.fromCredential(newUserCredential);
        } catch (e, stackTrace) {
          _logger.e(
            'Failed to create new user',
            error: e,
            stackTrace: stackTrace,
          );
          throw AuthException('Failed to create user');
        }
      }

      throw AuthException(_mapFirebaseErrorToMessage(e.code));
    } catch (e, stackTrace) {
      _logger.e(
        'Unexpected error during authentication',
        error: e,
        stackTrace: stackTrace,
      );
      throw AuthException('Authentication failed');
    }
  }

  @override
  Future<bool> tryLogOut() async {
    try {
      await _authClient.signOut();
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to sign out',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<String?> uploadMapPin(MapPinModel pin) async {
    try {
      // Get current user ID
      final userId = _authClient.currentUser?.uid;
      if (userId == null) {
        _logger.w('Attempted to upload map pin without authentication');
        return null;
      }

      // Add timestamp and user ID to the data
      final data = {
        ...pin.toJson(),
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Remove id if it's null to let Firebase generate one
      if (data['id'] == null) {
        data.remove('id');
      }

      // Upload to Firestore
      final docRef = await _firestore.collection(_mapPinsCollection).add(data);
      _logger.i('Successfully uploaded map pin with ID: ${docRef.id}');

      return docRef.id;
    } on FirebaseException catch (e, stackTrace) {
      _logger.e(
        'Firebase error while uploading map pin',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } catch (e, stackTrace) {
      _logger.e(
        'Unexpected error while uploading map pin',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<bool> updateMapPin(String documentId, MapPinModel pin) async {
    try {
      // Get current user ID
      final userId = _authClient.currentUser?.uid;
      if (userId == null) {
        _logger.w('Attempted to update map pin without authentication');
        return false;
      }

      // Get the existing document
      final docRef = _firestore.collection(_mapPinsCollection).doc(documentId);
      final doc = await docRef.get();

      // Verify document exists and belongs to current user
      if (!doc.exists) {
        _logger.w('Attempted to update non-existent map pin');
        return false;
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != userId) {
        _logger.w('Attempted to update map pin owned by different user');
        return false;
      }

      // Update the document while preserving userId and createdAt
      await docRef.update({
        ...pin.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Preserve original userId and createdAt
        'userId': data['userId'],
        'createdAt': data['createdAt'],
      });

      _logger.i('Successfully updated map pin with ID: $documentId');
      return true;
    } on FirebaseException catch (e, stackTrace) {
      _logger.e(
        'Firebase error while updating map pin',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } catch (e, stackTrace) {
      _logger.e(
        'Unexpected error while updating map pin',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<UserCredential> _signInUser(String email, String password) async {
    return await _authClient.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> _createUser(String email, String password) async {
    return await _authClient.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  String _mapFirebaseErrorToMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address';
      case 'wrong-password':
        return 'Invalid password';
      case 'user-disabled':
        return 'User account has been disabled';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'operation-not-allowed':
        return 'Operation not allowed';
      case 'weak-password':
        return 'Password is too weak';
      default:
        return 'Authentication failed';
    }
  }
}
