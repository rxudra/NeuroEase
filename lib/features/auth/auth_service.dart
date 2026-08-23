import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;

  Future<User> signUp({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    String role = 'patient',
  }) async {
    final validRole = (role == 'caregiver') ? 'caregiver' : 'patient';
    try {
      debugPrint("========== SIGN UP STARTED ==========");
      debugPrint("Email: $email");

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Your account could not be created.',
        );
      }

      debugPrint("Firebase Authentication Success");
      debugPrint("UID: ${user.uid}");

      await user.updateDisplayName(fullName.trim());

      debugPrint("Creating Firestore document...");

      await _createUserDocument(
        user,
        fullName: fullName,
        phoneNumber: phoneNumber,
        provider: 'password',
        role: validRole,
      );

      debugPrint("Firestore document created.");
      debugPrint("========== SIGN UP SUCCESS ==========");

      return user;
    } on FirebaseAuthException catch (e, s) {
      debugPrint("");
      debugPrint("========================================");
      debugPrint("FIREBASE AUTH EXCEPTION");
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");
      debugPrint("Exception: $e");
      debugPrintStack(stackTrace: s);
      debugPrint("========================================");
      debugPrint("");

      rethrow;
    } on FirebaseException catch (e, s) {
      debugPrint("");
      debugPrint("========================================");
      debugPrint("FIREBASE EXCEPTION");
      debugPrint("Plugin: ${e.plugin}");
      debugPrint("Code: ${e.code}");
      debugPrint("Message: ${e.message}");
      debugPrintStack(stackTrace: s);
      debugPrint("========================================");
      debugPrint("");

      rethrow;
    } catch (e, s) {
      debugPrint("");
      debugPrint("========================================");
      debugPrint("UNKNOWN EXCEPTION");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
      debugPrint("========================================");
      debugPrint("");

      rethrow;
    }
  }

  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'We could not sign you in.',
      );
    }

    return user;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<User> signInWithGoogle() async {
    final UserCredential credential;

    if (kIsWeb) {
      credential = await _auth.signInWithPopup(GoogleAuthProvider());
    } else {
      await _ensureGoogleInitialized();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError(
          'Google Sign-In is not supported on this device.',
        );
      }

      final googleUser = await _googleSignIn.authenticate();

      final googleAuthentication = googleUser.authentication;

      final idToken = googleAuthentication.idToken;

      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'Google did not return an ID token.',
        );
      }

      credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    }

    final user = credential.user;

    if (user == null) {
      throw FirebaseAuthException(code: 'google-sign-in-failed');
    }

    await _createUserDocument(
      user,
      fullName: user.displayName ?? '',
      phoneNumber: user.phoneNumber ?? '',
      provider: 'google',
    );

    return user;
  }

  Future<void> signOut() async {
    if (_googleInitialized) {
      await _googleSignIn.signOut();
    }

    await _auth.signOut();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();

    _googleInitialized = true;
  }

  Future<void> _createUserDocument(
    User user, {
    required String fullName,
    required String phoneNumber,
    required String provider,
    String role = 'patient',
  }) async {
    final document = _firestore.collection('users').doc(user.uid);

    final snapshot = await document.get();
    final validRole = (role == 'caregiver') ? 'caregiver' : 'patient';

    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'provider': provider,
      'role': validRole,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await document.set(data, SetOptions(merge: true));
  }

  Future<String> getUserRole(String uid) async {
    if (uid.trim().isEmpty) return 'patient';
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return 'patient';
      final role = doc.data()?['role'] as String?;
      if (role == 'caregiver') return 'caregiver';
      if (role == 'patient') return 'patient';
      return 'patient';
    } catch (_) {
      return 'patient';
    }
  }

  static String messageFor(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'The email or password is incorrect.';

        case 'email-already-in-use':
          return 'An account already exists for this email address.';

        case 'weak-password':
          return 'Use a stronger password with at least 8 characters.';

        case 'network-request-failed':
          return 'Check your internet connection and try again.';

        case 'too-many-requests':
          return 'Too many attempts. Please wait and try again.';

        case 'operation-not-allowed':
          return 'This sign-in method is not enabled yet.';

        case 'account-exists-with-different-credential':
          return 'This email is already linked to another sign-in method.';
      }

      return error.message ?? 'Authentication failed. Please try again.';
    }

    if (error is UnsupportedError) {
      return error.message ?? 'This action is unavailable.';
    }

    return 'Something went wrong. Please try again.';
  }
}
