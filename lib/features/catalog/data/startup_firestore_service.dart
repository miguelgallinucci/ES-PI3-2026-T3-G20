import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/startup_model.dart';

class StartupFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<StartupModel>> watchStartups() {
    return _firestore
        .collection('startups')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return StartupModel.fromFirestore(doc.data());
      }).toList();
    });
  }
}
