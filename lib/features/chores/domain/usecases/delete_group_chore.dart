import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class DeleteGroupChore implements UseCase<void, DeleteGroupChoreParams> {
  final ChoreRepository repository;

  DeleteGroupChore({required this.repository});

  @override
  Future<void> call(DeleteGroupChoreParams params) async {
    return await repository.deleteGroupChore(params.groupChore);
  }
}

class DeleteGroupChoreParams extends Equatable {
  final GroupChoreEntity groupChore;

  const DeleteGroupChoreParams({required this.groupChore});

  @override
  List<Object?> get props => [groupChore];
}
