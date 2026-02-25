import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

class GetSingleChores implements UseCase<List<SingleChoreEntity>, NoParams> {
  @override
  Future<List<SingleChoreEntity>> call(NoParams params) {
    return Future.value(<SingleChoreEntity>[]);
  }
}
