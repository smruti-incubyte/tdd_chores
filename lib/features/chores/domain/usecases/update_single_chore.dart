import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class UpdateSingleChore implements UseCase<void, UpdateSingleChoreParams> {
  final ChoreRepository repository;

  UpdateSingleChore({required this.repository});

  @override
  Future<void> call(UpdateSingleChoreParams params) async {
    return await repository.updateSingleChore(params);
  }
}

class UpdateSingleChoreParams extends Equatable {
  final SingleChoreEntity chore;

  const UpdateSingleChoreParams({required this.chore});

  @override
  List<Object?> get props => [chore];
}
