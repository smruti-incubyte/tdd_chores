import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/data/datasources/remote/chore_firebase_service.dart';
import 'package:tdd_chores/features/chores/data/models/group_chore.dart';
import 'package:tdd_chores/features/chores/data/models/single_chore.dart';
import 'package:tdd_chores/features/chores/data/repositories/chore_repository_impl.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

import 'chore_repository_impl.mocks.dart';

@GenerateMocks([ChoreFirebaseService])
void main() {
  late MockChoreFirebaseService mockChoreFirebaseService;
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
  final tGroupChoreEntity = GroupChoreEntity(
    id: '1',
    dateTime: tDateTime,
    chores: [
      const GroupChoreItem(
        id: '1',
        name: 'Wash dishes',
        status: ChoreStatus.todo,
      ),
    ],
  );

  final tGroupChoreModel = GroupChoreModel(
    id: '1',
    dateTime: tDateTime,
    chores: [
      const GroupChoreItem(
        id: '1',
        name: 'Wash dishes',
        status: ChoreStatus.todo,
      ),
    ],
  );

  setUp(() {
    mockChoreFirebaseService = MockChoreFirebaseService();
  });
  group('addSingleChore', () {
    test('should convert entity to model and call service', () async {
      when(
        mockChoreFirebaseService.addSingleChore(tSingleChoreModel),
      ).thenAnswer((_) async => {});
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await repository.addSingleChore(tSingleChoreEntity);
      verify(mockChoreFirebaseService.addSingleChore(tSingleChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });

    test('should throw an exception if the service throws', () async {
      when(
        mockChoreFirebaseService.addSingleChore(tSingleChoreModel),
      ).thenThrow(Exception('Service error'));
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await expectLater(
        repository.addSingleChore(tSingleChoreEntity),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getSingleChores', () {
    test(
      'should return list of single chores entities from service models',
      () async {
        when(
          mockChoreFirebaseService.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChoreModel]);
        final repository = ChoreRepositoryImpl(
          choreFirebaseService: mockChoreFirebaseService,
        );
        final result = await repository.getSingleChores();
        expect(result, equals([tSingleChoreEntity]));
      },
    );
    test('should throw an exception if the service throws', () async {
      when(
        mockChoreFirebaseService.getSingleChores(),
      ).thenThrow(Exception('Service error'));
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await expectLater(
        repository.getSingleChores(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateSingleChore', () {
    test('should convert entity to model and call service', () async {
      when(
        mockChoreFirebaseService.updateSingleChore(tSingleChoreModel),
      ).thenAnswer((_) async => {});
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await repository.updateSingleChore(tSingleChoreEntity);
      verify(mockChoreFirebaseService.updateSingleChore(tSingleChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });

    test('should throw an exception if the service throws', () async {
      when(
        mockChoreFirebaseService.updateSingleChore(tSingleChoreModel),
      ).thenThrow(Exception('Service error'));
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await expectLater(
        repository.updateSingleChore(tSingleChoreEntity),
        throwsA(isA<Exception>()),
      );
      verify(mockChoreFirebaseService.updateSingleChore(tSingleChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });
  });

  group('deleteSingleChore', () {
    test('should convert entity to model and call service', () async {
      when(
        mockChoreFirebaseService.deleteSingleChore(tSingleChoreModel),
      ).thenAnswer((_) async => {});
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await repository.deleteSingleChore(tSingleChoreEntity);
      verify(mockChoreFirebaseService.deleteSingleChore(tSingleChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });

    test('should throw an exception if the service throws', () async {
      when(
        mockChoreFirebaseService.deleteSingleChore(tSingleChoreModel),
      ).thenThrow(Exception('Service error'));
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await expectLater(
        repository.deleteSingleChore(tSingleChoreEntity),
        throwsA(isA<Exception>()),
      );
      verify(mockChoreFirebaseService.deleteSingleChore(tSingleChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });
  });

  group('getGroupChores', () {
    test(
      'should return list of group chores entities from service models',
      () async {
        when(
          mockChoreFirebaseService.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChoreModel]);
        final repository = ChoreRepositoryImpl(
          choreFirebaseService: mockChoreFirebaseService,
        );
        final result = await repository.getGroupChores();
        expect(result, equals([tGroupChoreEntity]));
      },
    );
    test('should throw an exception if the service throws', () async {
      when(
        mockChoreFirebaseService.getGroupChores(),
      ).thenThrow(Exception('Service error'));
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await expectLater(repository.getGroupChores(), throwsA(isA<Exception>()));
      verify(mockChoreFirebaseService.getGroupChores());
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });
  });

  group('addGroupChore', () {
    test('should convert entity to model and call service', () async {
      when(
        mockChoreFirebaseService.addGroupChore(tGroupChoreModel),
      ).thenAnswer((_) async => {});
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await repository.addGroupChore(tGroupChoreEntity);
      verify(mockChoreFirebaseService.addGroupChore(tGroupChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });
    test('should throw an exception if the service throws', () async {
      when(
        mockChoreFirebaseService.addGroupChore(tGroupChoreModel),
      ).thenThrow(Exception('Service error'));
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await expectLater(
        repository.addGroupChore(tGroupChoreEntity),
        throwsA(isA<Exception>()),
      );
      verify(mockChoreFirebaseService.addGroupChore(tGroupChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });
  });

  group('updateGroupChore', () {
    test('should convert entity to model and call service', () async {
      when(
        mockChoreFirebaseService.updateGroupChore(tGroupChoreModel),
      ).thenAnswer((_) async => {});
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await repository.updateGroupChore(tGroupChoreEntity);
      verify(mockChoreFirebaseService.updateGroupChore(tGroupChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });
    test('should throw an exception if the service throws', () async {
      when(
        mockChoreFirebaseService.updateGroupChore(tGroupChoreModel),
      ).thenThrow(Exception('Service error'));
      final repository = ChoreRepositoryImpl(
        choreFirebaseService: mockChoreFirebaseService,
      );
      await expectLater(
        repository.updateGroupChore(tGroupChoreEntity),
        throwsA(isA<Exception>()),
      );
      verify(mockChoreFirebaseService.updateGroupChore(tGroupChoreModel));
      verifyNoMoreInteractions(mockChoreFirebaseService);
    });
  });
}
