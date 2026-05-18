import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StartupQuestionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

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
    if (question.trim().isEmpty) {
      throw Exception('A pergunta não pode ser vazia.');
    }

    try {
      final callable = _functions.httpsCallable('sendQuestion');
      await callable.call({
        'startupId': startupId,
        'startupName': startupName,
        'question': question,
      });
    } catch (e) {
      throw Exception('Falha ao enviar pergunta: $e');
    }
  }
}