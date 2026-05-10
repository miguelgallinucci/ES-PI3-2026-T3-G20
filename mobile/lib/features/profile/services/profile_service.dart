// Serviço responsável por gerenciar os dados do perfil do usuário.
// 
// Centraliza a leitura do documento do usuário no Firestore e operações
// relacionadas ao perfil.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retorna o usuário autenticado no Firebase.
  User? get currentUser => _auth.currentUser;

  /// Observa em tempo real o documento do perfil do usuário atual no Firestore.
  Stream<DocumentSnapshot<Map<String, dynamic>>>? watchCurrentUserProfile() {
    final uid = currentUser?.uid;

    if (uid == null) {
      return null;
    }

    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Realiza o logout do usuário.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
