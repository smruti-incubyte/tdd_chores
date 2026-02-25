import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_bloc.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';

void main() {
  group('GetSingleChoresEvent', () {
    blocTest<ChoresBloc, ChoresState>(
      'emits [ChoresLoading, ChoresLoaded] on success',
      build: () {
        return ChoresBloc(ChoresInitial());
      },
    );
  });
}
