import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

void main() {
  test('should get list of single chores from repository', () {
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
  });
}
