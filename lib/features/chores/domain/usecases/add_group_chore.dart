import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class AddGroupChore implements UseCase<void, AddGroupChoreParams> {
  final ChoreRepository repository;

  AddGroupChore({required this.repository});

  @override
  Future<void> call(AddGroupChoreParams params) async {
    return await repository.addGroupChore(params.groupChore);
  }
}

class AddGroupChoreParams extends Equatable {
  final GroupChoreEntity groupChore;

  const AddGroupChoreParams({required this.groupChore});

  @override
  List<Object?> get props => [groupChore];
}
