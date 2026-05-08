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
import 'package:firebase_auth/firebase_auth.dart';

// Classe de serviço para gerenciar operações de portfólio
class WalletService {
  // Instância do Firestore para acesso à base de dados
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Instância do Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserPortfolio() {
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

  // Garante que o campo de saldo fictício existe no documento do usuário
  // Se o campo não existir, ele é criado com valor inicial 0.0
  // Lança Exception se o usuário não estiver autenticado ou se os dados não forem encontrados
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

  // Adiciona um aporte simulado ao saldo do usuário
  // Executa de forma atômica uma transação que:
  // 1. Atualiza o saldoFicticio do usuário
  // 2. Cria um registro da transação na coleção 'transactions'
  //
  // Lança Exception se:
  // - O usuário não estiver autenticado
  // - O valor for menor ou igual a zero
  // - Os dados do usuário não forem encontrados
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