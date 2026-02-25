import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/usecases/get_single_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChoresBloc extends Bloc<ChoresEvent, ChoresState> {
  final GetSingleChores getSingleChores;
  ChoresBloc(ChoresInitial choresInitial, {required this.getSingleChores})
    : super(ChoresInitial()) {
    on<GetSingleChoresEvent>(_onGetSingleChoresEvent);
  }

  Future<void> _onGetSingleChoresEvent(
    GetSingleChoresEvent event,
    Emitter<ChoresState> emit,
  ) async {
    final result = await getSingleChores(NoParams());
  }
}
