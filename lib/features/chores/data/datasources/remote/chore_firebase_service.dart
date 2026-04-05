import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tdd_chores/features/chores/data/models/group_chore.dart';
import 'package:tdd_chores/features/chores/data/models/single_chore.dart';

class ChoreFirebaseService {
  ChoreFirebaseService({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const _singleChoresCollection = 'single_chores';
  static const _singleChorePhotosFolder = 'single_chores';

  Future<void> addSingleChore(SingleChoreModel chore) async {
    final collection = _firestore.collection(_singleChoresCollection);

    if (chore.id != null) {
      await collection.doc(chore.id).set(chore.toJson());
      return;
    }

    await collection.add(chore.toJson());
  }

  Future<List<SingleChoreModel>> getSingleChores() async {
    return await _firestore
        .collection(_singleChoresCollection)
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
        .collection(_singleChoresCollection)
        .doc(chore.id)
        .update(chore.toJson());
  }

  Future<void> deleteSingleChore(SingleChoreModel chore) async {
    await _firestore.collection(_singleChoresCollection).doc(chore.id).delete();
  }

  Future<String> savePhoto(String choreId, String photoPath) async {
    final storageRef = _storage
        .ref()
        .child(_singleChorePhotosFolder)
        .child(choreId)
        .child(_photoFileName(photoPath));

    await storageRef.putFile(File(photoPath));

    return storageRef.getDownloadURL();
  }

  Future<void> deletePhoto(String photoUrl) async {
    await _storage.refFromURL(photoUrl).delete();
  }

  Future<List<GroupChoreModel>> getGroupChores() async {
    return await _firestore
        .collection('group_chores')
        .get()
        .then(
          (value) => value.docs
              .map((doc) => GroupChoreModel.fromJson(doc.data(), docId: doc.id))
              .toList(),
        );
  }

  Future<void> addGroupChore(GroupChoreModel chore) async {
    await _firestore.collection('group_chores').add({...chore.toJson()});
  }

  Future<void> updateGroupChore(GroupChoreModel chore) async {
    await _firestore
        .collection('group_chores')
        .doc(chore.id)
        .update(chore.toJson());
  }

  Future<void> deleteGroupChore(GroupChoreModel chore) async {
    await _firestore.collection('group_chores').doc(chore.id).delete();
  }

  String _photoFileName(String photoPath) {
    final pathSegments = Uri.file(photoPath).pathSegments;

    if (pathSegments.isEmpty) {
      return 'photo';
    }

    return pathSegments.last;
  }
}
