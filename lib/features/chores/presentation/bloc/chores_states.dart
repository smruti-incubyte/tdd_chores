import 'package:equatable/equatable.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

abstract class ChoresState extends Equatable {
  const ChoresState();

  @override
  List<Object?> get props => [];
}

class ChoresInitial extends ChoresState {}

class ChoresLoading extends ChoresState {}

class ChoresLoaded extends ChoresState {
  final List<SingleChoreEntity> singleChores;
  const ChoresLoaded({required this.singleChores});
  @override
  List<Object?> get props => [singleChores];
}

class ChoresError extends ChoresState {
  final String message;
  const ChoresError(String string, {required this.message});
  @override
  List<Object?> get props => [message];
}
