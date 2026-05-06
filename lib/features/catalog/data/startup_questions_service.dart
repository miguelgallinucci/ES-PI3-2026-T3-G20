import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StartupQuestionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _questionsCollection {
    return _firestore.collection('questions');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchQuestions({
    required String startupId,
  }) {
    return _questionsCollection
        .where('startupId', isEqualTo: startupId)
        .where('isPublic', isEqualTo: true)
        .snapshots();
  }

  Future<void> sendQuestion({
    required String startupId,
    required String startupName,
    required String question,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    await _questionsCollection.add({
      'startupId': startupId,
      'startupName': startupName,
      'question': question,
      'answer': '',
      'createdAt': FieldValue.serverTimestamp(),
      'answeredAt': null,
      'userId': user.uid,
      'userName': user.displayName ?? '',
      'userEmail': user.email ?? '',
      'isPublic': true,
      'status': 'aguardando_resposta',
    });
  }
}