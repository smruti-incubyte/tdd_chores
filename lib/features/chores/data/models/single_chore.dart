import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

class SingleChoreModel extends SingleChoreEntity {
  const SingleChoreModel({
    required super.id,
    required super.name,
    required super.dateTime,
    required super.status,
  });

  factory SingleChoreModel.fromEntity(SingleChoreEntity entity) {
    return SingleChoreModel(
      id: entity.id,
      name: entity.name,
      dateTime: entity.dateTime,
      status: entity.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'dateTime': dateTime, 'status': status};
  }

  factory SingleChoreModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    return SingleChoreModel(
      id: docId ?? json['id'],
      name: json['name'],
      dateTime: json['dateTime'],
      status: json['status'],
    );
  }

  SingleChoreEntity toEntity() {
    return SingleChoreEntity(
      id: id,
      name: name,
      dateTime: dateTime,
      status: status,
    );
  }
}
