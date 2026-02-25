import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class GetGroupChores implements UseCase<List<GroupChoreEntity>, NoParams> {
  final ChoreRepository repository;

  GetGroupChores({required this.repository});

  @override
  Future<List<GroupChoreEntity>> call(NoParams params) async {
    return await repository.getGroupChores();
  }
}
