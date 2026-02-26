import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_single_chore.dart'
    show DeleteSingleChore;
import 'package:tdd_chores/features/chores/domain/usecases/get_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_single_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_bloc.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';

import '../../domain/chores_domain_test.mocks.dart';

void main() {
  late MockChoreRepository mockChoreRepository;
  late ChoresBloc choresBloc;

  setUp(() {
    mockChoreRepository = MockChoreRepository();
    choresBloc = ChoresBloc(
      addGroupChore: AddGroupChore(repository: mockChoreRepository),
      updateGroupChore: UpdateGroupChore(repository: mockChoreRepository),
      deleteSingleChore: DeleteSingleChore(repository: mockChoreRepository),
      updateSingleChore: UpdateSingleChore(repository: mockChoreRepository),
      getSingleChores: GetSingleChores(repository: mockChoreRepository),
      addSingleChore: AddSingleChore(repository: mockChoreRepository),
      getGroupChores: GetGroupChores(repository: mockChoreRepository),
    );
  });

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
          addGroupChore: AddGroupChore(repository: mockChoreRepository),
          updateGroupChore: UpdateGroupChore(repository: mockChoreRepository),
          deleteSingleChore: DeleteSingleChore(repository: mockChoreRepository),
          updateSingleChore: UpdateSingleChore(repository: mockChoreRepository),
          getSingleChores: GetSingleChores(repository: mockChoreRepository),
          addSingleChore: AddSingleChore(repository: mockChoreRepository),
          getGroupChores: GetGroupChores(repository: mockChoreRepository),
        );
      },
      act: (bloc) {
        bloc.add(GetSingleChoresEvent());
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [tSingleChore], groupChores: []),
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
          addGroupChore: AddGroupChore(repository: mockChoreRepository),
          updateGroupChore: UpdateGroupChore(repository: mockChoreRepository),
          deleteSingleChore: DeleteSingleChore(repository: mockChoreRepository),
          updateSingleChore: UpdateSingleChore(repository: mockChoreRepository),
          addSingleChore: AddSingleChore(repository: mockChoreRepository),
          getSingleChores: GetSingleChores(repository: mockChoreRepository),
          getGroupChores: GetGroupChores(repository: mockChoreRepository),
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

  group('GetGroupChoresEvent', () {
    final tGroupChores = [
      GroupChoreEntity(
        id: '1',
        dateTime: DateTime(2024, 1, 1),
        chores: [
          GroupChoreItem(id: '1', name: 'Test Chore', status: ChoreStatus.todo),
        ],
      ),
    ];
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed groupChores on success',
      build: () {
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => tGroupChores);
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        return choresBloc;
      },
      act: (bloc) {
        bloc.add(GetGroupChoresEvent());
        return choresBloc;
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [], groupChores: tGroupChores),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.getGroupChores()).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when getGroupChores throws',
      build: () {
        when(
          mockChoreRepository.getGroupChores(),
        ).thenThrow(Exception('Error'));
        return choresBloc;
      },
      act: (bloc) {
        bloc.add(GetGroupChoresEvent());
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('Error', message: 'Error getting group chores'),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.getGroupChores()).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'verifies getGroupChores is called with correct params',
      build: () {
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => tGroupChores);
        return choresBloc;
      },
      act: (bloc) {
        bloc.add(GetGroupChoresEvent());
      },
      verify: (bloc) {
        verify(mockChoreRepository.getGroupChores()).called(1);
      },
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
        ChoresLoaded(singleChores: [tSingleChore], groupChores: []),
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

  group('AddGroupChoresEvent', () {
    final tGroupChore = GroupChoreEntity(
      id: '1',
      dateTime: DateTime(2024, 1, 1),
      chores: [
        GroupChoreItem(id: '1', name: 'Test Chore', status: ChoreStatus.todo),
      ],
    );
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed groupChores on success',
      build: () {
        return choresBloc;
      },
      act: (bloc) {
        when(
          mockChoreRepository.addGroupChore(tGroupChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        bloc.add(AddGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [], groupChores: [tGroupChore]),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.addGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when addGroupChore throws',
      build: () {
        when(
          mockChoreRepository.addGroupChore(tGroupChore),
        ).thenThrow(Exception('add failed'));
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(AddGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('add failed', message: 'Error adding group chore'),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.addGroupChore(tGroupChore)).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'verifies addGroupChore is called with correct params',
      build: () {
        when(
          mockChoreRepository.addGroupChore(tGroupChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(AddGroupChoresEvent(groupChore: tGroupChore));
      },
      verify: (bloc) {
        verify(mockChoreRepository.addGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
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
        when(
          mockChoreRepository.updateSingleChore(tSingleChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return bloc.add(UpdateSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [tSingleChore], groupChores: []),
      ],
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when updateSingleChore throws',
      build: () {
        when(
          mockChoreRepository.updateSingleChore(tSingleChore),
        ).thenThrow(Exception('update failed'));
        return choresBloc;
      },
      act: (bloc) {
        when(
          mockChoreRepository.updateSingleChore(any),
        ).thenThrow(Exception('update failed'));
        return bloc.add(UpdateSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('update failed', message: 'Error updating single chore'),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.updateSingleChore(tSingleChore)).called(1);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'verifies updateSingleChore is called with correct params',
      build: () {
        when(
          mockChoreRepository.updateSingleChore(any),
        ).thenAnswer((_) async {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(UpdateSingleChoresEvent(chore: tSingleChore));
      },
      verify: (_) {
        verify(mockChoreRepository.updateSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
      },
    );
  });

  group('UpdateGroupChoresEvent', () {
    final tGroupChore = GroupChoreEntity(
      id: '1',
      dateTime: DateTime(2024, 1, 1),
      chores: [
        GroupChoreItem(id: '1', name: 'Test Chore', status: ChoreStatus.todo),
      ],
    );
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed groupChores on success',
      build: () {
        return choresBloc;
      },
      act: (bloc) {
        when(
          mockChoreRepository.updateGroupChore(tGroupChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        return bloc.add(UpdateGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [], groupChores: [tGroupChore]),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.updateGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when updateGroupChore throws',
      build: () {
        when(
          mockChoreRepository.updateGroupChore(tGroupChore),
        ).thenThrow(Exception('update failed'));
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        return choresBloc;
      },
      act: (bloc) {
        bloc.add(UpdateGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('update failed', message: 'Error updating group chore'),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.updateGroupChore(tGroupChore)).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'verifies updateGroupChore is called with correct params',
      build: () {
        when(
          mockChoreRepository.updateGroupChore(tGroupChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(UpdateGroupChoresEvent(groupChore: tGroupChore));
      },
      verify: (bloc) {
        verify(mockChoreRepository.updateGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
      },
    );
  });
  group('DeleteSingleChoresEvent', () {
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
        when(
          mockChoreRepository.deleteSingleChore(tSingleChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [tSingleChore], groupChores: []),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.deleteSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when deleteSingleChore throws',
      build: () {
        when(
          mockChoreRepository.deleteSingleChore(tSingleChore),
        ).thenThrow(Exception('delete failed'));
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('delete failed', message: 'Error deleting single chore'),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.deleteSingleChore(tSingleChore)).called(1);
      },
    );
    blocTest<ChoresBloc, ChoresState>(
      'verifies deleteSingleChore is called with correct params',
      build: () {
        when(
          mockChoreRepository.deleteSingleChore(any),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChore));
      },
      verify: (_) {
        verify(mockChoreRepository.deleteSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
      },
    );
  });
  group('DeleteGroupChoresEvent', () {
    final tGroupChore = GroupChoreEntity(
      id: '1',
      dateTime: DateTime(2024, 1, 1),
      chores: [
        GroupChoreItem(id: '1', name: 'Test Chore', status: ChoreStatus.todo),
      ],
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed groupChores on success',
      build: () {
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(DeleteGroupChoresEvent(groupChore: tGroupChore));
      },
    );
  });
}
