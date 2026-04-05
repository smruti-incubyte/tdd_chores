import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
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
import 'package:tdd_chores/features/chores/presentation/bloc/chores_bloc.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';

import '../../domain/chores_domain_test.mocks.dart';

void main() {
  late MockChoreRepository mockChoreRepository;
  late ChoresBloc choresBloc;
  const tPhotoUrl = 'https://example.com/photo.jpg';
  const tPhotoPath = '/tmp/photo.jpg';

  final tSingleChore = SingleChoreEntity(
    createdBy: '1',
    id: '1',
    name: 'Test Chore',
    dateTime: DateTime(2024, 1, 1),
    status: ChoreStatus.todo,
  );

  final tSingleChoreWithPhoto = SingleChoreEntity(
    createdBy: '1',
    id: '1',
    name: 'Test Chore',
    dateTime: DateTime(2024, 1, 1),
    status: ChoreStatus.todo,
    photoUrl: tPhotoUrl,
  );

  final tGroupChore = GroupChoreEntity(
    createdBy: '1',
    id: '1',
    dateTime: DateTime(2024, 1, 1),
    chores: [
      GroupChoreItem(id: '1', name: 'Test Chore', status: ChoreStatus.todo),
    ],
  );

  ChoresBloc makeBloc() => ChoresBloc(
    deleteGroupChore: DeleteGroupChore(repository: mockChoreRepository),
    deletePhoto: DeletePhoto(repository: mockChoreRepository),
    addGroupChore: AddGroupChore(repository: mockChoreRepository),
    updateGroupChore: UpdateGroupChore(repository: mockChoreRepository),
    deleteSingleChore: DeleteSingleChore(repository: mockChoreRepository),
    updateSingleChore: UpdateSingleChore(repository: mockChoreRepository),
    getSingleChores: GetSingleChores(repository: mockChoreRepository),
    addSingleChore: AddSingleChore(repository: mockChoreRepository),
    getGroupChores: GetGroupChores(repository: mockChoreRepository),
    savePhoto: SavePhoto(repository: mockChoreRepository),
  );

  setUp(() {
    mockChoreRepository = MockChoreRepository();
    choresBloc = makeBloc();
  });

  group('GetSingleChoresEvent', () {
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoading, ChoresLoaded] on success',
      build: () {
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return makeBloc();
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
        return makeBloc();
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
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed groupChores on success',
      build: () {
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        return choresBloc;
      },
      act: (bloc) {
        bloc.add(GetGroupChoresEvent());
        return choresBloc;
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [], groupChores: [tGroupChore]),
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
        ).thenAnswer((_) async => [tGroupChore]);
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
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed singleChores on success when photo is selected',
      build: () {
        when(
          mockChoreRepository.savePhoto(tSingleChore.id!, tPhotoPath),
        ).thenAnswer((_) async => tPhotoUrl);
        when(
          mockChoreRepository.addSingleChore(tSingleChoreWithPhoto),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChoreWithPhoto]);
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(
          AddSingleChoresEvent(chore: tSingleChore, photoPath: tPhotoPath),
        );
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [tSingleChoreWithPhoto], groupChores: []),
      ],
      verify: (bloc) {
        verifyInOrder([
          mockChoreRepository.savePhoto(tSingleChore.id!, tPhotoPath),
          mockChoreRepository.addSingleChore(tSingleChoreWithPhoto),
          mockChoreRepository.getSingleChores(),
        ]);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed singleChores on success when no photo is selected',
      build: () {
        when(
          mockChoreRepository.addSingleChore(tSingleChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(AddSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [tSingleChore], groupChores: []),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.addSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
        verifyNever(mockChoreRepository.savePhoto(any, any));
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when savePhoto throws',
      build: () {
        when(
          mockChoreRepository.savePhoto(tSingleChore.id!, tPhotoPath),
        ).thenThrow(Exception('save photo failed'));
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(
          AddSingleChoresEvent(chore: tSingleChore, photoPath: tPhotoPath),
        );
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('save photo failed', message: 'Error adding single chore'),
      ],
      verify: (bloc) {
        verify(
          mockChoreRepository.savePhoto(tSingleChore.id!, tPhotoPath),
        ).called(1);
        verifyNever(mockChoreRepository.addSingleChore(any));
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when addSingleChore throws after savePhoto succeeds',
      build: () {
        when(
          mockChoreRepository.savePhoto(tSingleChore.id!, tPhotoPath),
        ).thenAnswer((_) async => tPhotoUrl);
        when(
          mockChoreRepository.addSingleChore(tSingleChoreWithPhoto),
        ).thenThrow(Exception('add failed'));
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(
          AddSingleChoresEvent(chore: tSingleChore, photoPath: tPhotoPath),
        );
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('add failed', message: 'Error adding single chore'),
      ],
      verify: (bloc) {
        verifyInOrder([
          mockChoreRepository.savePhoto(tSingleChore.id!, tPhotoPath),
          mockChoreRepository.addSingleChore(tSingleChoreWithPhoto),
        ]);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'verifies addSingleChore is called with correct params when no photo is selected',
      build: () {
        when(
          mockChoreRepository.addSingleChore(tSingleChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(AddSingleChoresEvent(chore: tSingleChore));
      },
      verify: (_) {
        verify(mockChoreRepository.addSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
        verifyNever(mockChoreRepository.savePhoto(any, any));
      },
    );
  });

  group('AddGroupChoresEvent', () {
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
        bloc.add(AddGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [], groupChores: [tGroupChore]),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.addGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
        verifyNever(mockChoreRepository.getSingleChores());
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
        return bloc.add(UpdateGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [], groupChores: [tGroupChore]),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.updateGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
        verifyNever(mockChoreRepository.getSingleChores());
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when updateGroupChore throws',
      build: () {
        when(
          mockChoreRepository.updateGroupChore(tGroupChore),
        ).thenThrow(Exception('update failed'));
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
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed singleChores on success when photoUrl is present',
      build: () {
        when(
          mockChoreRepository.deletePhoto(tPhotoUrl),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.deleteSingleChore(tSingleChoreWithPhoto),
        ).thenAnswer((_) async => {});
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChoreWithPhoto));
      },
      expect: () => [
        ChoresLoading(),
        const ChoresLoaded(singleChores: [], groupChores: []),
      ],
      verify: (bloc) {
        verifyInOrder([
          mockChoreRepository.deletePhoto(tPhotoUrl),
          mockChoreRepository.deleteSingleChore(tSingleChoreWithPhoto),
          mockChoreRepository.getSingleChores(),
        ]);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed singleChores on success when photoUrl is null',
      build: () {
        when(
          mockChoreRepository.deleteSingleChore(tSingleChore),
        ).thenAnswer((_) async => {});
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChore));
      },
      expect: () => [
        ChoresLoading(),
        const ChoresLoaded(singleChores: [], groupChores: []),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.deleteSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
        verifyNever(mockChoreRepository.deletePhoto(any));
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when deletePhoto throws',
      build: () {
        when(
          mockChoreRepository.deletePhoto(tPhotoUrl),
        ).thenThrow(Exception('delete photo failed'));
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChoreWithPhoto));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError(
          'delete photo failed',
          message: 'Error deleting single chore',
        ),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.deletePhoto(tPhotoUrl)).called(1);
        verifyNever(mockChoreRepository.deleteSingleChore(any));
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when deleteSingleChore throws after deletePhoto succeeds',
      build: () {
        when(
          mockChoreRepository.deletePhoto(tPhotoUrl),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.deleteSingleChore(tSingleChoreWithPhoto),
        ).thenThrow(Exception('delete failed'));
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChoreWithPhoto));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('delete failed', message: 'Error deleting single chore'),
      ],
      verify: (bloc) {
        verifyInOrder([
          mockChoreRepository.deletePhoto(tPhotoUrl),
          mockChoreRepository.deleteSingleChore(tSingleChoreWithPhoto),
        ]);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'verifies deleteSingleChore is called with correct params when photoUrl is null',
      build: () {
        when(
          mockChoreRepository.deleteSingleChore(any),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getSingleChores(),
        ).thenAnswer((_) async => [tSingleChore]);
        return makeBloc();
      },
      act: (bloc) {
        return bloc.add(DeleteSingleChoresEvent(chore: tSingleChore));
      },
      verify: (_) {
        verify(mockChoreRepository.deleteSingleChore(tSingleChore)).called(1);
        verify(mockChoreRepository.getSingleChores()).called(1);
        verifyNever(mockChoreRepository.deletePhoto(any));
      },
    );
  });

  group('DeleteGroupChoresEvent', () {
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoaded] with refreshed groupChores on success',
      build: () {
        return choresBloc;
      },
      act: (bloc) {
        when(
          mockChoreRepository.deleteGroupChore(tGroupChore),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        return bloc.add(DeleteGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresLoaded(singleChores: [], groupChores: [tGroupChore]),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.deleteGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
        verifyNever(mockChoreRepository.getSingleChores());
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresError] when deleteGroupChore throws',
      build: () {
        when(
          mockChoreRepository.deleteGroupChore(tGroupChore),
        ).thenThrow(Exception('delete failed'));
        return choresBloc;
      },
      act: (bloc) {
        return bloc.add(DeleteGroupChoresEvent(groupChore: tGroupChore));
      },
      expect: () => [
        ChoresLoading(),
        ChoresError('delete failed', message: 'Error deleting group chore'),
      ],
      verify: (bloc) {
        verify(mockChoreRepository.deleteGroupChore(tGroupChore)).called(1);
      },
    );

    blocTest<ChoresBloc, ChoresState>(
      'verifies deleteGroupChore is called with correct params',
      build: () {
        when(
          mockChoreRepository.deleteGroupChore(any),
        ).thenAnswer((_) async => {});
        when(
          mockChoreRepository.getGroupChores(),
        ).thenAnswer((_) async => [tGroupChore]);
        return choresBloc;
      },
      act: (bloc) {
        bloc.add(DeleteGroupChoresEvent(groupChore: tGroupChore));
      },
      verify: (bloc) {
        verify(mockChoreRepository.deleteGroupChore(tGroupChore)).called(1);
        verify(mockChoreRepository.getGroupChores()).called(1);
        verifyNever(mockChoreRepository.getSingleChores());
      },
    );
  });
}
