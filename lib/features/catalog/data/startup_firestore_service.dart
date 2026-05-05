import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/startup_model.dart';

class StartupFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<StartupModel>> watchStartups() {
    return _firestore.collection('startups').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return StartupModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }
}