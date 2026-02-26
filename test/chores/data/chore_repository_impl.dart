import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/data/repositories/chore_repository_impl.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

void main() {
  final tDateTime = DateTime(2024, 1, 1);

  final tSingleChoreEntity = SingleChoreEntity(
    id: '1',
    name: 'Test Chore',
    dateTime: tDateTime,
    status: ChoreStatus.todo,
  );

  final tSingleChoreModel = SingleChoreModel(
    id: '1',
    name: 'Test Chore',
    dateTime: tDateTime,
    status: ChoreStatus.todo,
  );

  test(
    'should return list of single chores entities from repository',
    () async {
      final repository = ChoreRepositoryImpl();
      final result = await repository.getSingleChores();
    },
  );
}
