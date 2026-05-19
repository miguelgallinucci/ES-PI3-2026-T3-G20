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

    // 1. Cria o usuário no Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Usuário nulo após createUserWithEmailAndPassword');
    }

    // 2. Obtém idToken fresco para enviar ao backend como fallback de autenticação.
    //    O context.auth do callable pode chegar vazio logo após o registro,
    //    então enviamos o token explicitamente no payload.
    final idToken = await user.getIdToken(true);
    debugPrint('idToken obtido com sucesso (${idToken?.length ?? 0} chars)');

    // 3. Chama a Cloud Function createUserProfile para criar users/{uid}
    try {
      final callable = _functions.httpsCallable('createUserProfile');
      await callable.call({
        'fullName': cleanFullName,
        'cpf': cleanCpf,
        'phone': cleanPhone,
        'idToken': idToken,
      });
      debugPrint('Perfil criado via Cloud Function para uid=${user.uid}');
    } catch (e) {
      debugPrint('Erro ao criar perfil no backend: $e');
      // Propaga o erro para a UI informar o usuário.
      // O cadastro no Auth já foi feito, mas sem perfil no Firestore
      // o app não funcionará corretamente.
      rethrow;
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