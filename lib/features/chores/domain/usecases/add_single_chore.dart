import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class AddSingleChore implements UseCase<void, AddSingleChoreParams> {
  final ChoreRepository repository;

  AddSingleChore({required this.repository});

  @override
  Future<void> call(AddSingleChoreParams params) async {
    return await repository.addSingleChore(params.chore);
  }
}

class AddSingleChoreParams extends Equatable {
  final SingleChoreEntity chore;

  const AddSingleChoreParams({required this.chore});

  @override
  List<Object?> get props => [chore];
}
