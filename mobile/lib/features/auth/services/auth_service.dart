import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  User? get currentUser {
    return _auth.currentUser;
  }

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    return await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );
  }

  Future<UserCredential> register({
    required String fullName,
    required String email,
    required String cpf,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanFullName = fullName.trim();
    final cleanCpf = cpf.trim();
    final cleanPhone = phone.trim();

    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    try {
      final callable = _functions.httpsCallable('createUserProfile');
      await callable.call({
        'fullName': cleanFullName,
        'cpf': cleanCpf,
        'phone': cleanPhone,
      });
    } catch (e) {
      debugPrint('Erro ao criar perfil no backend: $e');
    }

    return credential;
  }

  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    final cleanEmail = email.trim();

    await _auth.sendPasswordResetEmail(
      email: cleanEmail,
    );
  }

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final document = await _firestore.collection('users').doc(user.uid).get();

    return document.data();
  }

  Future<bool> isMfaEnabled() async {
    final userData = await getCurrentUserData();
    return userData?['mfaEnabled'] == true;
  }

  Future<void> setMfaEnabled(bool enabled) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set(
      {
        'mfaEnabled': enabled,
        'mfaUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}