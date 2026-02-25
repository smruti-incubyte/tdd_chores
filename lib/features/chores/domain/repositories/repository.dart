import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

abstract class ChoreRepository {
  Future<List<SingleChoreEntity>> getSingleChores();
  Future<void> addSingleChore(SingleChoreEntity chore);
  Future<void> updateSingleChore(SingleChoreEntity chore);
  Future<void> deleteSingleChore(SingleChoreEntity chore);
  Future<List<GroupChoreEntity>> getGroupChores();
  Future<void> addGroupChore(GroupChoreEntity groupChore);
  Future<void> updateGroupChore(GroupChoreEntity groupChore);
}
