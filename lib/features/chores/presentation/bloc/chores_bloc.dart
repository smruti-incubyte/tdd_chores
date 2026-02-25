import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChoresBloc extends Bloc<ChoresEvent, ChoresState> {
  ChoresBloc(ChoresInitial choresInitial) : super(ChoresInitial());
}
