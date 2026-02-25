import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_single_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChoresBloc extends Bloc<ChoresEvent, ChoresState> {
  final GetSingleChores getSingleChores;
  final AddSingleChore addSingleChore;
  final UpdateSingleChore updateSingleChore;
  final DeleteSingleChore deleteSingleChore;
  final GetGroupChores getGroupChores;
  final AddGroupChore addGroupChore;
  ChoresBloc({
    required this.getSingleChores,
    required this.addSingleChore,
    required this.updateSingleChore,
    required this.deleteSingleChore,
    required this.getGroupChores,
    required this.addGroupChore,
  }) : super(ChoresInitial()) {
    on<GetSingleChoresEvent>(_onGetSingleChoresEvent);
    on<AddSingleChoresEvent>(_onAddSingleChoresEvent);
    on<UpdateSingleChoresEvent>(_onUpdateSingleChoresEvent);
    on<DeleteSingleChoresEvent>(_onDeleteSingleChoresEvent);
    on<GetGroupChoresEvent>(_onGetGroupChoresEvent);
    on<AddGroupChoresEvent>(_onAddGroupChoresEvent);
  }

  Future<void> _onGetSingleChoresEvent(
    GetSingleChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      emit(ChoresLoading());
      final result = await getSingleChores(NoParams());
      emit(ChoresLoaded(singleChores: result, groupChores: []));
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
      emit(ChoresLoaded(singleChores: singleChores, groupChores: []));
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error adding single chore'));
    }
  }

  Future<void> _onUpdateSingleChoresEvent(
    UpdateSingleChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      emit(ChoresLoading());
      await updateSingleChore(UpdateSingleChoreParams(chore: event.chore));
      final singleChores = await getSingleChores(NoParams());
      emit(ChoresLoaded(singleChores: singleChores, groupChores: []));
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error updating single chore'));
    }
  }

  Future<void> _onDeleteSingleChoresEvent(
    DeleteSingleChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      emit(ChoresLoading());
      await deleteSingleChore(DeleteSingleChoreParams(chore: event.chore));
      final singleChores = await getSingleChores(NoParams());
      emit(ChoresLoaded(singleChores: singleChores, groupChores: []));
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error deleting single chore'));
    }
  }

  Future<void> _onGetGroupChoresEvent(
    GetGroupChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      emit(ChoresLoading());
      final result = await getGroupChores(NoParams());
      final singleChores = await getSingleChores(NoParams());
      emit(ChoresLoaded(groupChores: result, singleChores: singleChores));
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error getting group chores'));
    }
  }

  Future<void> _onAddGroupChoresEvent(
    AddGroupChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      emit(ChoresLoading());
      await addGroupChore(AddGroupChoreParams(groupChore: event.groupChore));
      final groupChores = await getGroupChores(NoParams());
      final singleChores = await getSingleChores(NoParams());
      emit(ChoresLoaded(groupChores: groupChores, singleChores: singleChores));
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error adding group chore'));
    }
  }
}
