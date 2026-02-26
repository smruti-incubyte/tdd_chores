import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/add_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/delete_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_group_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/domain/usecases/update_group_chore.dart';
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
  final UpdateGroupChore updateGroupChore;
  final DeleteGroupChore deleteGroupChore;
  ChoresBloc({
    required this.getSingleChores,
    required this.addSingleChore,
    required this.updateSingleChore,
    required this.deleteSingleChore,
    required this.getGroupChores,
    required this.addGroupChore,
    required this.updateGroupChore,
    required this.deleteGroupChore,
  }) : super(ChoresInitial()) {
    on<GetSingleChoresEvent>(_onGetSingleChoresEvent);
    on<AddSingleChoresEvent>(_onAddSingleChoresEvent);
    on<UpdateSingleChoresEvent>(_onUpdateSingleChoresEvent);
    on<DeleteSingleChoresEvent>(_onDeleteSingleChoresEvent);
    on<GetGroupChoresEvent>(_onGetGroupChoresEvent);
    on<AddGroupChoresEvent>(_onAddGroupChoresEvent);
    on<UpdateGroupChoresEvent>(_onUpdateGroupChoresEvent);
    on<DeleteGroupChoresEvent>(_onDeleteGroupChoresEvent);
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
    } catch (e, s) {
      print('Error getting group chores: $e $s');
      emit(ChoresError(e.toString(), message: 'Error getting group chores'));
    }
  }

  Future<void> _onAddGroupChoresEvent(
    AddGroupChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      final currentSingleChores = state is ChoresLoaded
          ? (state as ChoresLoaded).singleChores
          : <SingleChoreEntity>[];
      emit(ChoresLoading());
      await addGroupChore(AddGroupChoreParams(groupChore: event.groupChore));
      final groupChores = await getGroupChores(NoParams());
      emit(
        ChoresLoaded(
          groupChores: groupChores,
          singleChores: currentSingleChores,
        ),
      );
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error adding group chore'));
    }
  }

  Future<void> _onUpdateGroupChoresEvent(
    UpdateGroupChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      final currentSingleChores = state is ChoresLoaded
          ? (state as ChoresLoaded).singleChores
          : <SingleChoreEntity>[];
      emit(ChoresLoading());
      await updateGroupChore(
        UpdateGroupChoreParams(groupChore: event.groupChore),
      );
      final groupChores = await getGroupChores(NoParams());
      emit(
        ChoresLoaded(
          groupChores: groupChores,
          singleChores: currentSingleChores,
        ),
      );
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error updating group chore'));
    }
  }

  Future<void> _onDeleteGroupChoresEvent(
    DeleteGroupChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    try {
      final currentSingleChores = state is ChoresLoaded
          ? (state as ChoresLoaded).singleChores
          : <SingleChoreEntity>[];
      emit(ChoresLoading());
      await deleteGroupChore(
        DeleteGroupChoreParams(groupChore: event.groupChore),
      );
      final groupChores = await getGroupChores(NoParams());
      emit(
        ChoresLoaded(
          groupChores: groupChores,
          singleChores: currentSingleChores,
        ),
      );
    } catch (e) {
      emit(ChoresError(e.toString(), message: 'Error deleting group chore'));
    }
  }
}
