import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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

  group('GetSingleChoresEvent', () {
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoading, ChoresLoaded] on success',
      build: () {
        when(mockChoreRepository.getSingleChores()).thenAnswer((_) async => []);
        return ChoresBloc(
          ChoresInitial(),
          getSingleChores: GetSingleChores(repository: mockChoreRepository),
        );
      },
      act: (bloc) {
        bloc.add(GetSingleChoresEvent());
      },
    );
  });
}
