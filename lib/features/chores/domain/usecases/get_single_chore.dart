import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class GetSingleChores implements UseCase<List<SingleChoreEntity>, NoParams> {
  final ChoreRepository repository;

  GetSingleChores({required this.repository});

  @override
  Future<List<SingleChoreEntity>> call(NoParams params) async {
    return await repository.getSingleChores();
  }
}
