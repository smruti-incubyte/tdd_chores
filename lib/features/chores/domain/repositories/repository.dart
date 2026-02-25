import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

abstract class ChoreRepository {
  Future<List<SingleChoreEntity>> getSingleChores();
}
