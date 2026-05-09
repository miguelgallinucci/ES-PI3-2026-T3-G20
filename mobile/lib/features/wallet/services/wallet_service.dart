// Serviço de Portfólio
//
// Responsável por gerenciar todas as operações de portfólio do usuário,
// incluindo:
// - Sincronização de dados do portfólio com Firestore (tempo real)
// - Monitoramento de transações do usuário
// - Gerenciamento de saldo fictício (saldoFicticio)
// - Adição de aportes simulados com registro de transação
//
// Utiliza Firebase Authentication para auténticação e Cloud Firestore
// para persistência de dados.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Classe de serviço para gerenciar operações de portfólio
class WalletService {
  // Instância do Firestore para acesso à base de dados
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Instância do Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Instância do Firebase Functions
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Retorna o ID do usuário autenticado atualmente
  // Pode ser null se o usuário não estiver autenticado
  String? get currentUserId => _auth.currentUser?.uid;

  // Retorna a referência ao documento do usuário no Firestore
  // Retorna null se o usuário não estiver autenticado
  DocumentReference<Map<String, dynamic>>? get _currentUserRef {
    final uid = currentUserId;

    if (uid == null) {
      return null;
    }

    return _firestore.collection('users').doc(uid);
  }

  // Observa em tempo real as alterações no portfólio do usuário atual
  // Retorna um Stream com o snapshot do documento do usuário
  // Lança Exception se o usuário não estiver autenticado
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserWallet() {
    final userRef = _currentUserRef;

    if (userRef == null) {
      throw Exception('Usuário não autenticado.');
    }

    return userRef.snapshots();
  }

  // Observa em tempo real todas as transações do usuário atual
  // Retorna um Stream com os snapshots das transações
  // Lança Exception se o usuário não estiver autenticado
  Stream<QuerySnapshot<Map<String, dynamic>>> watchUserTransactions() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('Usuário não autenticado.');
    }

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }


  // Adiciona um aporte simulado ao saldo do usuário via Cloud Functions
  //
  // Lança Exception se:
  // - O valor for menor ou igual a zero
  // - Ocorrer algum erro na chamada da função
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