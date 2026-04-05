import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_photo.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/save_photo.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_group_chore.dart';
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
        createdBy: '1',
        id: '1',
        name: 'Test Chore 1',
        dateTime: DateTime(2024, 1, 1),
        status: ChoreStatus.todo,
      ),
      SingleChoreEntity(
        createdBy: '1',
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
      createdBy: '1',
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
      createdBy: '1',
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
      createdBy: '1',
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

  test('should save a photo through repository', () async {
    const tChoreId = '1';
    const tPhotoPath = '/tmp/photo.jpg';
    const tPhotoUrl = 'https://example.com/photo.jpg';

    when(mockChoreRepository.savePhoto(tChoreId, tPhotoPath)).thenAnswer(
      (_) async => tPhotoUrl,
    );

    final useCase = SavePhoto(repository: mockChoreRepository);
    final result = await useCase(
      const SavePhotoParams(choreId: tChoreId, photoPath: tPhotoPath),
    );

    expect(result, equals(tPhotoUrl));
    verify(mockChoreRepository.savePhoto(tChoreId, tPhotoPath));
    verifyNoMoreInteractions(mockChoreRepository);
  });

  test('should delete a photo through repository', () async {
    const tPhotoUrl = 'https://example.com/photo.jpg';

    when(mockChoreRepository.deletePhoto(tPhotoUrl)).thenAnswer((_) async => {});

    final useCase = DeletePhoto(repository: mockChoreRepository);
    await useCase(const DeletePhotoParams(photoUrl: tPhotoUrl));

    verify(mockChoreRepository.deletePhoto(tPhotoUrl));
    verifyNoMoreInteractions(mockChoreRepository);
  });

  test('should get list of group chores from repository', () async {
    final tGroupChores = [
      GroupChoreEntity(
        createdBy: '1',
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
      createdBy: '1',
      id: '1',
      chores: [
        GroupChoreItem(id: '1', name: 'Test Chore 1', status: ChoreStatus.todo),
      ],
      dateTime: DateTime(2024, 1, 1),
    );

    when(
      mockChoreRepository.addGroupChore(tGroupChore),
    ).thenAnswer((_) async => {});

    final useCase = AddGroupChore(repository: mockChoreRepository);
    await useCase(AddGroupChoreParams(groupChore: tGroupChore));
    verify(mockChoreRepository.addGroupChore(tGroupChore));
    verifyNoMoreInteractions(mockChoreRepository);
  });

  test('should update a group chore in repository', () async {
    final tGroupChore = GroupChoreEntity(
      createdBy: '1',
      id: '1',
      chores: [
        GroupChoreItem(id: '1', name: 'Test Chore 1', status: ChoreStatus.todo),
      ],
      dateTime: DateTime(2024, 1, 1),
    );

    when(
      mockChoreRepository.updateGroupChore(tGroupChore),
    ).thenAnswer((_) async => {});

    final useCase = UpdateGroupChore(repository: mockChoreRepository);
    await useCase(UpdateGroupChoreParams(groupChore: tGroupChore));
    verify(mockChoreRepository.updateGroupChore(tGroupChore));
    verifyNoMoreInteractions(mockChoreRepository);
  });

  test('should delete a group chore from repository', () async {
    final tGroupChore = GroupChoreEntity(
      createdBy: '1',
      id: '1',
      chores: [
        GroupChoreItem(id: '1', name: 'Test Chore 1', status: ChoreStatus.todo),
      ],
      dateTime: DateTime(2024, 1, 1),
    );

    when(
      mockChoreRepository.deleteGroupChore(tGroupChore),
    ).thenAnswer((_) async => {});

    final useCase = DeleteGroupChore(repository: mockChoreRepository);
    await useCase(DeleteGroupChoreParams(groupChore: tGroupChore));
    verify(mockChoreRepository.deleteGroupChore(tGroupChore));
    verifyNoMoreInteractions(mockChoreRepository);
  });
}
