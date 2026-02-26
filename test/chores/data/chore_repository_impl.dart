import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/data/datasources/remote/chore_firebase_service.dart';
import 'package:tdd_chores/features/chores/data/models/single_chore.dart';
import 'package:tdd_chores/features/chores/data/repositories/chore_repository_impl.dart';
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
    });
  });
}
