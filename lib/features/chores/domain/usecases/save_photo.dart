import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class SavePhoto implements UseCase<String, SavePhotoParams> {
  final ChoreRepository repository;

  SavePhoto({required this.repository});

  @override
  Future<String> call(SavePhotoParams params) {
    return repository.savePhoto(params.choreId, params.photoPath);
  }
}

class SavePhotoParams extends Equatable {
  final String choreId;
  final String photoPath;

  const SavePhotoParams({
    required this.choreId,
    required this.photoPath,
  });

  @override
  List<Object?> get props => [choreId, photoPath];
}
