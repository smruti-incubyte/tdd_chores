import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_single_chore.dart';

import 'chores_domain_test.mocks.dart';

@GenerateMocks([ChoreRepository])
void main() {
  late MockChoreRepository mockChoreRepository;

  setUp(() {
    mockChoreRepository = MockChoreRepository();
  });

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

    when(
      mockChoreRepository.getSingleChores(),
    ).thenAnswer((_) async => tChores);

    final useCase = GetSingleChores(repository: mockChoreRepository);
    final result = await useCase(NoParams());
    expect(result, equals(tChores));
  });

  test('should add a single chore to repository', () async {
    final tChore = SingleChoreEntity(
      id: '1',
      name: 'Test Chore 1',
      dateTime: DateTime(2024, 1, 1),
      status: ChoreStatus.todo,
    );

    when(
      mockChoreRepository.addSingleChore(tChore),
    ).thenAnswer((_) async => {});
    final useCase = AddSingleChore(repository: mockChoreRepository);
    await useCase(AddSingleChoreParams(chore: tChore));
    verify(mockChoreRepository.addSingleChore(tChore));
    verifyNoMoreInteractions(mockChoreRepository);
  });

  test('should update a single chore in repository', () async {
    final tChore = SingleChoreEntity(
      id: '1',
      name: 'Updated Chore',
      dateTime: DateTime(2024, 1, 1),
      status: ChoreStatus.todo,
    );

    when(
      mockChoreRepository.updateSingleChore(tChore),
    ).thenAnswer((_) async => {});

    final useCase = UpdateSingleChore(repository: mockChoreRepository);
    await useCase(UpdateSingleChoreParams(chore: tChore));
    verify(mockChoreRepository.updateSingleChore(tChore));
    verifyNoMoreInteractions(mockChoreRepository);
  });

  test('should delete a single chore from repository', () async {
    final tChore = SingleChoreEntity(
      id: '1',
      name: 'Test Chore 1',
      dateTime: DateTime(2024, 1, 1),
      status: ChoreStatus.todo,
    );

    when(
      mockChoreRepository.deleteSingleChore(tChore),
    ).thenAnswer((_) async => {});

    final useCase = DeleteSingleChore(repository: mockChoreRepository);
    await useCase(DeleteSingleChoreParams(chore: tChore));
    verify(mockChoreRepository.deleteSingleChore(tChore));
    verifyNoMoreInteractions(mockChoreRepository);
  });

  test('should get list of group chores from repository', () async {
    final tGroupChores = [
      GroupChoreEntity(
        id: '1',
        chores: [
          GroupChoreItem(
            id: '1',
            name: 'Test Chore 1',
            status: ChoreStatus.todo,
          ),
        ],
        dateTime: DateTime(2024, 1, 1),
      ),
    ];

    when(
      mockChoreRepository.getGroupChores(),
    ).thenAnswer((_) async => tGroupChores);

    final useCase = GetGroupChores(repository: mockChoreRepository);
    final result = await useCase(NoParams());
    expect(result, equals(tGroupChores));
  });

  test('should add a group chore to repository', () async {
    final tGroupChore = GroupChoreEntity(
      id: '1',
      chores: [
        GroupChoreItem(id: '1', name: 'Test Chore 1', status: ChoreStatus.todo),
      ],
      dateTime: DateTime(2024, 1, 1),
    );

    final useCase = AddGroupChore(repository: mockChoreRepository);
  });
}
