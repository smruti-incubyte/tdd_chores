import 'package:tdd_chores/features/chores/data/datasources/remote/chore_firebase_service.dart';
import 'package:tdd_chores/features/chores/data/models/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class ChoreRepositoryImpl implements ChoreRepository {
  final ChoreFirebaseService choreFirebaseService;
  ChoreRepositoryImpl({required this.choreFirebaseService});
  @override
  Future<void> addGroupChore(GroupChoreEntity groupChore) {
    // TODO: implement addGroupChore
    throw UnimplementedError();
  }

  @override
  Future<void> addSingleChore(SingleChoreEntity chore) async {
    await choreFirebaseService.addSingleChore(
      SingleChoreModel.fromEntity(chore),
    );
  }

  @override
  Future<void> deleteGroupChore(GroupChoreEntity groupChore) {
    // TODO: implement deleteGroupChore
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSingleChore(SingleChoreEntity chore) {
    // TODO: implement deleteSingleChore
    throw UnimplementedError();
  }

  @override
  Future<List<GroupChoreEntity>> getGroupChores() {
    // TODO: implement getGroupChores
    throw UnimplementedError();
  }

  @override
  Future<List<SingleChoreEntity>> getSingleChores() async {
    final chores = await choreFirebaseService.getSingleChores();
    return chores.map((chore) => chore.toEntity()).toList();
  }

  @override
  Future<void> updateGroupChore(GroupChoreEntity groupChore) {
    // TODO: implement updateGroupChore
    throw UnimplementedError();
  }

  @override
  Future<void> updateSingleChore(SingleChoreEntity chore) async {
    await choreFirebaseService.updateSingleChore(
      SingleChoreModel.fromEntity(chore),
    );
  }
}
