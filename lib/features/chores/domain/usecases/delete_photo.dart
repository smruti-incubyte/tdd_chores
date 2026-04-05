import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/usecase/usecase.dart';
import 'package:tdd_chores/features/chores/domain/repositories/repository.dart';

class DeletePhoto implements UseCase<void, DeletePhotoParams> {
  final ChoreRepository repository;

  DeletePhoto({required this.repository});

  @override
  Future<void> call(DeletePhotoParams params) {
    return repository.deletePhoto(params.photoUrl);
  }
}

class DeletePhotoParams extends Equatable {
  final String photoUrl;

  const DeletePhotoParams({required this.photoUrl});

  @override
  List<Object?> get props => [photoUrl];
}
