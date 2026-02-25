import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_bloc.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';

import '../../domain/chores_domain_test.mocks.dart';

void main() {
  late MockChoreRepository mockChoreRepository;

  setUp(() {
    mockChoreRepository = MockChoreRepository();
  });
  ChoresBloc choresBloc = ChoresBloc(
    getSingleChores: GetSingleChores(repository: mockChoreRepository),
    addSingleChore: AddSingleChore(repository: mockChoreRepository),
  );

  group('GetSingleChoresEvent', () {
    final tDateTime = DateTime(2024, 1, 1);
    final tSingleChore = SingleChoreEntity(
      id: '1',
      name: 'Test Chore',
      dateTime: tDateTime,
      status: ChoreStatus.todo,
    );
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoading, ChoresLoaded] on success',
      build: () {
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return ChoresBloc(
          getSingleChores: GetSingleChores(repository: mockChoreRepository),
          addSingleChore: AddSingleChore(repository: mockChoreRepository),
        );
      },
      act: (bloc) {
        bloc.add(GetSingleChoresEvent());
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [tSingleChore]),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.getSingleChores()).called(1);
      },
    );

    blocTest(
      'emits [ChoresLoading, ChoresError] when the get single chores fails',
      build: () {
        when(
          mockChoreRepository.getSingleChores(),
        ).thenThrow(Exception('Error'));
        return ChoresBloc(
          addSingleChore: AddSingleChore(repository: mockChoreRepository),
          getSingleChores: GetSingleChores(repository: mockChoreRepository),
        );
      },
      act: (bloc) {
        bloc.add(GetSingleChoresEvent());
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('Error', message: 'Error getting single chores'),
      ],
    );
  });

  group('AddSingleChoresEvent', () {
    final tDateTime = DateTime(2024, 1, 1);
    final tSingleChore = SingleChoreEntity(
      id: '1',
      name: 'Test Chore',
      dateTime: tDateTime,
      status: ChoreStatus.todo,
    );
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed singleChores on success',
      build: () {
        return choresBloc;
      },
      act: (bloc) {
        when(
          mockChoreRepository.addSingleChore(tSingleChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return bloc.add(AddSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [tSingleChore]),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.addSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when addSingleChore throws',
      build: () {
        when(
          mockChoreRepository.addSingleChore(any),
        ).thenThrow(Exception('add failed'));
        return choresBloc;
      },
      act: (bloc) {
        when(
          mockChoreRepository.addSingleChore(tSingleChore),
        ).thenThrow(Exception('add failed'));
        return bloc.add(AddSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('add failed', message: 'Error adding single chore'),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.addSingleChore(tSingleChore)).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'verifies addSingleChore is called with correct params',
      build: () {
        when(
          mockChoreRepository.addSingleChore(tSingleChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(AddSingleChoresEvent(chore: tSingleChore));
      },
      verify: (_) {
        verify(mockChoreRepository.addSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
      },
    );
  });
  group('UpdateSingleChoresEvent', () {
    final tDateTime = DateTime(2024, 1, 1);
    final tSingleChore = SingleChoreEntity(
      id: '1',
      name: 'Test Chore',
      dateTime: tDateTime,
      status: ChoreStatus.todo,
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed singleChores on success',
      build: () {
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(UpdateSingleChoresEvent(chore: tSingleChore));
      },
    );
  });
}
