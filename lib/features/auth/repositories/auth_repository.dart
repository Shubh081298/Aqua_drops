import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthRepository {
  AuthRepository({required this.auth, required this.firestore});

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found'    => 'No account found with this email.',
      'wrong-password'    => 'Incorrect password.',
      'invalid-email'     => 'Please enter a valid email address.',
      'user-disabled'     => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'invalid-credential'=> 'Invalid email or password.',
      _                   => 'Sign in failed. Please try again.',
    };
  }
}
