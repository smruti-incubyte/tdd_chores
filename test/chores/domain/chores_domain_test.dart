import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';

void main() {
  test('should get list of single chores from repository', () async {
    final tChores = [
      SingleChoreEntity(
        id: '1',
        name: 'Test Chore 1',
        dateTime: DateTime(2024, 1, 1),
        status: ChoreStatus.todo,
      ),
      SingleChoreEntity(
        id: '2',
        name: 'Test Chore 2',
        dateTime: DateTime(2024, 1, 2),
        status: ChoreStatus.done,
      ),
    ];

    final useCase = GetSingleChores();
    final result = await useCase(NoParams());
    expect(result, equals(tChores));
  });
}
