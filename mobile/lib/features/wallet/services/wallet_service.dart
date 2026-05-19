import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _currentUserRef {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    return _firestore.collection('users').doc(uid);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserWallet() {
    final userRef = _currentUserRef;

    if (userRef == null) {
      throw Exception('Usuario nao autenticado.');
    }

    return userRef.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserTransactions() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('Usuario nao autenticado.');
    }

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserPositions() {
    final userRef = _currentUserRef;

    if (userRef == null) {
      throw Exception('Usuario nao autenticado.');
    }

    return userRef.collection('positions').snapshots();
  }

  Future<void> addSimulatedBalance(double amount) async {
    if (amount <= 0) {
      throw Exception('O valor precisa ser maior que zero.');
    }

    try {
      final callable = _functions.httpsCallable('addSimulatedBalance');
      await callable.call({
        'amount': amount,
      });
    } catch (e) {
      throw Exception('Falha ao adicionar saldo simulado: $e');
    }
  }
}
