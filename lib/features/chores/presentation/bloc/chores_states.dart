import 'package:equatable/equatable.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
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
  final List<GroupChoreEntity> groupChores;
  const ChoresLoaded({required this.singleChores, required this.groupChores});
  @override
  List<Object?> get props => [singleChores, groupChores];
}

class ChoresError extends ChoresState {
  final String message;
  const ChoresError(String string, {required this.message});
  @override
  List<Object?> get props => [message];
}
