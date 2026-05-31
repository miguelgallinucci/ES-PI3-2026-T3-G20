// Alycia Santos Bond - RA 25016465
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

  // Retorna o stream do histórico de transações do usuário logado.
  // As regras do Firestore garantem que o usuário só pode ler suas próprias transações
  // (resource.data.userId == request.auth.uid) e proíbem qualquer escrita (allow write: if false).
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

  // Adiciona saldo fictício à carteira do usuário.
  // Chama a Cloud Function 'addSimulatedBalance' enviando o valor desejado.
  // A Cloud Function valida se o valor é positivo e realiza a atualização
  // usando uma transação atômica do Firestore, garantindo consistência no backend.
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
