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
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-creation-failed',
        message: 'Your account could not be created. Please try again.',
      );
    }

    await user.updateDisplayName(fullName.trim());
    await _createUserDocument(
      user,
      fullName: fullName,
      phoneNumber: phoneNumber,
      provider: 'password',
    );
    return user;
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
        message: 'We could not sign you in. Please try again.',
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
          message:
              'Google did not provide an identity token. Please try again.',
        );
      }

      credential = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    }

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'We could not sign you in with Google. Please try again.',
      );
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
    if (_googleInitialized) return;
    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<void> _createUserDocument(
    User user, {
    required String fullName,
    required String phoneNumber,
    required String provider,
  }) async {
    final document = _firestore.collection('users').doc(user.uid);
    final snapshot = await document.get();
    final data = <String, dynamic>{
      'uid': user.uid,
      'email': user.email ?? '',
      'displayName': fullName.trim(),
      'phoneNumber': phoneNumber.trim(),
      'provider': provider,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await document.set(data, SetOptions(merge: true));
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
    if (error is UnsupportedError)
      return error.message ?? 'This action is unavailable.';
    return 'Something went wrong. Please try again.';
  }
}
