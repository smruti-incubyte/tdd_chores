import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class UpdateGroupChore implements UseCase<void, UpdateGroupChoreParams> {
  final ChoreRepository repository;

  UpdateGroupChore({required this.repository});

  @override
  Future<void> call(UpdateGroupChoreParams params) async {
    return await repository.updateGroupChore(params.groupChore);
  }
}

class UpdateGroupChoreParams extends Equatable {
  final GroupChoreEntity groupChore;

  const UpdateGroupChoreParams({required this.groupChore});

  @override
  List<Object?> get props => [groupChore];
}
