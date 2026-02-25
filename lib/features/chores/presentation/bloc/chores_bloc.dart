import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChoresBloc extends Bloc<ChoresEvent, ChoresState> {
  final GetSingleChores getSingleChores;
  final AddSingleChore addSingleChore;
  ChoresBloc({required this.getSingleChores, required this.addSingleChore})
    : super(ChoresInitial()) {
    on<GetSingleChoresEvent>(_onGetSingleChoresEvent);
    on<AddSingleChoresEvent>(_onAddSingleChoresEvent);
  }

  Future<void> _onGetSingleChoresEvent(
    GetSingleChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      emit(ChoresLoading());
      final result = await getSingleChores(NoParams());
      emit(ChoresLoaded(singleChores: result));
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error getting single chores'));
    }
  }

  Future<void> _onAddSingleChoresEvent(
    AddSingleChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      emit(ChoresLoading());
      await addSingleChore(AddSingleChoreParams(chore: event.chore));
      final singleChores = await getSingleChores(NoParams());
      emit(ChoresLoaded(singleChores: singleChores));
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error adding single chore'));
    }
  }
}
