import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/enums/enums.dart';

class GroupChoreItem extends Equatable {
  final String id;
  final String name;
  final ChoreStatus status;

  const GroupChoreItem({
    required this.id,
    required this.name,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'status': status.name};
  }

  factory GroupChoreItem.fromJson(Map<String, dynamic> json) {
    print('GroupChoreItem.fromJson-${json}');
    return GroupChoreItem(
      id: json['id']?.toString() ?? '1',
      name: json['name'] as String,
      status: ChoreStatus.values.byName(json['status'] as String),
    );
  }

  @override
  List<Object?> get props => [id, name, status];

  GroupChoreItem copyWith({required ChoreStatus status}) {
    return GroupChoreItem(id: id, name: name, status: status);
  }
}

class GroupChoreEntity extends Equatable {
  final String id;
  final DateTime dateTime;
  final List<GroupChoreItem> chores;

  const GroupChoreEntity({
    required this.id,
    required this.dateTime,
    required this.chores,
  });

  @override
  List<Object?> get props => [id, dateTime, chores];
}
