import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

    final uid = credential.user!.uid;

    await _firestore.collection('users').doc(uid).set({
      'fullName': cleanFullName,
      'email': cleanEmail,
      'cpf': cleanCpf,
      'phone': cleanPhone,
      'role': 'investidor',
      'mfaEnabled': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

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

    final document = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    return document.data();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}