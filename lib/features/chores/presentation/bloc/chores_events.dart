import 'package:equatable/equatable.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

abstract class ChoresEvent extends Equatable {
  const ChoresEvent();

  @override
  List<Object?> get props => [];
}

class GetSingleChoresEvent extends ChoresEvent {}

class AddSingleChoresEvent extends ChoresEvent {
  final SingleChoreEntity chore;
  const AddSingleChoresEvent({required this.chore});
  @override
  List<Object?> get props => [chore];
}

class UpdateSingleChoresEvent extends ChoresEvent {
  final SingleChoreEntity chore;
  const UpdateSingleChoresEvent({required this.chore});
  @override
  List<Object?> get props => [chore];
}

class DeleteSingleChoresEvent extends ChoresEvent {
  final SingleChoreEntity chore;
  const DeleteSingleChoresEvent({required this.chore});
  @override
  List<Object?> get props => [chore];
}

class GetGroupChoresEvent extends ChoresEvent {}

class AddGroupChoresEvent extends ChoresEvent {
  final GroupChoreEntity groupChore;
  const AddGroupChoresEvent({required this.groupChore});
  @override
  List<Object?> get props => [groupChore];
}
