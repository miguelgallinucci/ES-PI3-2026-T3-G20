import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _currentUserRef {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    return _firestore.collection('users').doc(uid);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserPortfolio() {
    final userRef = _currentUserRef;

    if (userRef == null) {
      throw Exception('Usuário não autenticado.');
    }

    return userRef.snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserTransactions() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> ensurePortfolioFieldExists() async {
    final userRef = _currentUserRef;

    if (userRef == null) {
      throw Exception('Usuário não autenticado.');
    }

    final userSnapshot = await userRef.get();
    final userData = userSnapshot.data();

    if (userData == null) {
      throw Exception('Dados do usuário não encontrados.');
    }

    if (!userData.containsKey('saldoFicticio')) {
      await userRef.update({
        'saldoFicticio': 0.0,
      });
    }
  }

  Future<void> addSimulatedBalance(double amount) async {
    final uid = currentUserId;
    final userRef = _currentUserRef;

    if (uid == null || userRef == null) {
      throw Exception('Usuário não autenticado.');
    }

    if (amount <= 0) {
      throw Exception('O valor precisa ser maior que zero.');
    }

    final transactionRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final userData = userSnapshot.data();

      if (userData == null) {
        throw Exception('Dados do usuário não encontrados.');
      }

      final currentBalance = (userData['saldoFicticio'] ?? 0).toDouble();
      final newBalance = currentBalance + amount;

      transaction.update(userRef, {
        'saldoFicticio': newBalance,
      });

      transaction.set(transactionRef, {
        'userId': uid,
        'tipo': 'aporte_simulado',
        'valorTotal': amount,
        'descricao': 'Adição de saldo simulado',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}