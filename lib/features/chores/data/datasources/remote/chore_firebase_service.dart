import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tdd_chores/features/chores/data/models/single_chore.dart';

class ChoreFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSingleChore(SingleChoreModel chore) async {
    await _firestore.collection('single_chores').add(chore.toJson());
  }
}
