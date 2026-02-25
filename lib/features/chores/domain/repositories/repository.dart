import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_single_chore.dart';

abstract class ChoreRepository {
  Future<List<SingleChoreEntity>> getSingleChores();
  Future<void> addSingleChore(AddSingleChoreParams params);
  Future<void> updateSingleChore(UpdateSingleChoreParams params);
}
