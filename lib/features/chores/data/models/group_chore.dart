import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';

class GroupChoreModel extends GroupChoreEntity {
  const GroupChoreModel({
    required super.id,
    required super.dateTime,
    required super.chores,
  });

  factory GroupChoreModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    print('GroupChoreModel.fromJson456-${json}-${docId}');
    return GroupChoreModel(
      id: docId ?? '1',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : DateTime.now(),
      chores: (json['chores'] as List<dynamic>?)
              ?.map((e) => GroupChoreItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'chores': chores.map((e) => e.toJson()).toList(),
    };
  }

  GroupChoreModel copyWith({
    String? id,
    required DateTime dateTime,
    required List<GroupChoreItem> chores,
  }) {
    return GroupChoreModel(
      id: id ?? this.id,
      dateTime: dateTime,
      chores: chores,
    );
  }

  factory GroupChoreModel.fromEntity(GroupChoreEntity chore) {
    return GroupChoreModel(
      id: chore.id,
      dateTime: chore.dateTime,
      chores: chore.chores
          .map((e) => GroupChoreItem(id: e.id, name: e.name, status: e.status))
          .toList(),
    );
  }

  GroupChoreEntity toEntity() {
    return GroupChoreEntity(
      id: id,
      dateTime: dateTime,
      chores: chores
          .map((e) => GroupChoreItem(id: e.id, name: e.name, status: e.status))
          .toList(),
    );
  }
}
