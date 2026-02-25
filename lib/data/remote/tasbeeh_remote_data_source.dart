import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/tasbeeh_model.dart';

class TasbeehRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> save(TasbeehModel model) async {
    final uid = _auth.currentUser!.uid;

    await _firestore.collection("users").doc(uid).set(model.toMap());
  }

  Future<TasbeehModel?> load() async {
    final uid = _auth.currentUser!.uid;
    final doc =
        await _firestore.collection("users").doc(uid).get();

    if (!doc.exists) return null;

    return TasbeehModel.fromMap(doc.data()!);
  }
}
