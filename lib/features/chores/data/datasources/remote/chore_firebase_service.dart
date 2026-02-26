import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tdd_chores/features/chores/data/models/single_chore.dart';

class ChoreFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSingleChore(SingleChoreModel chore) async {
    await _firestore.collection('single_chores').add(chore.toJson());
  }

  Future<List<SingleChoreModel>> getSingleChores() async {
    return await _firestore
        .collection('single_chores')
        .get()
        .then(
          (value) => value.docs
              .map(
                (doc) => SingleChoreModel.fromJson(doc.data(), docId: doc.id),
              )
              .toList(),
        );
  }

  Future<void> updateSingleChore(SingleChoreModel chore) async {
    await _firestore
        .collection('single_chores')
        .doc(chore.id)
        .update(chore.toJson());
  }

  Future<void> deleteSingleChore(SingleChoreModel chore) async {
    await _firestore.collection('single_chores').doc(chore.id).delete();
  }
}
