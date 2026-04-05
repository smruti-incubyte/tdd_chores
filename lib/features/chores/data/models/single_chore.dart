import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';

class SingleChoreModel extends SingleChoreEntity {
  const SingleChoreModel({
    super.id,
    required super.name,
    required super.dateTime,
    required super.status,
    required super.createdBy,
    super.photoUrl,
  });

  factory SingleChoreModel.fromJson(
    Map<String, dynamic> json, {
    String? docId,
  }) {
    return SingleChoreModel(
      id: docId,
      name: json['name'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      status: ChoreStatus.values.byName(json['status'] as String),
      createdBy: json['createdBy'] as String,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'createdBy': createdBy,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  SingleChoreModel copyWith({
    String? id,
    required String name,
    required DateTime dateTime,
    required ChoreStatus status,
    required String createdBy,
    String? photoUrl,
  }) {
    return SingleChoreModel(
      id: id ?? this.id,
      name: name,
      dateTime: dateTime,
      status: status,
      createdBy: createdBy,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory SingleChoreModel.fromEntity(SingleChoreEntity chore) {
    return SingleChoreModel(
      id: chore.id,
      name: chore.name,
      dateTime: chore.dateTime,
      status: chore.status,
      createdBy: chore.createdBy,
      photoUrl: chore.photoUrl,
    );
  }

  SingleChoreEntity toEntity() {
    return SingleChoreEntity(
      id: id,
      name: name,
      dateTime: dateTime,
      status: status,
      createdBy: createdBy,
      photoUrl: photoUrl,
    );
  }
}
