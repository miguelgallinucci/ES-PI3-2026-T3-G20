// Serviço responsável pelo processo de compra de tokens.
// 
// Centraliza a comunicação com o Firebase Functions para a operação
// de investimento e gerencia a leitura de dados necessários para a transação.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TokenPurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Retorna o ID do usuário atual ou null se não autenticado.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Busca o saldo disponível do usuário no Firestore.
  Future<double> getUserBalance() async {
    final uid = currentUserId;
    if (uid == null) return 0.0;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final data = userDoc.data();
    
    if (data == null) return 0.0;
    
    final saldo = data['saldoFicticio'];
    if (saldo is num) return saldo.toDouble();
    
    return 0.0;
  }

  /// Executa a chamada para compra de tokens via Cloud Function.
  Future<void> buyTokens({
    required String startupId,
    required int quantity,
  }) async {
    try {
      final callable = _functions.httpsCallable('buyTokens');
      await callable.call({
        'startupId': startupId,
        'quantity': quantity,
      });
    } catch (e) {
      rethrow;
    }
  }
}
