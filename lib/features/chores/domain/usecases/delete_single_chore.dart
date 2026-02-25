import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class DeleteSingleChore implements UseCase<void, DeleteSingleChoreParams> {
  final ChoreRepository repository;

  DeleteSingleChore({required this.repository});

  @override
  Future<void> call(DeleteSingleChoreParams params) async {
    return await repository.deleteSingleChore(params);
  }
}

class DeleteSingleChoreParams extends Equatable {
  final SingleChoreEntity chore;

  const DeleteSingleChoreParams({required this.chore});

  @override
  List<Object?> get props => [chore];
}
