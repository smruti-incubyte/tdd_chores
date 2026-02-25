import 'package:equatable/equatable.dart';
import 'package:tdd_chores/core/enums/enums.dart';

class GroupChoreEntity extends Equatable {
  final String id;
  final List<GroupChoreItem> chores;
  final DateTime dateTime;

  const GroupChoreEntity({
    required this.id,
    required this.chores,
    required this.dateTime,
  });
  @override
  List<Object?> get props => [id, chores, dateTime];
}

class GroupChoreItem extends Equatable {
  final String id;
  final String name;
  final ChoreStatus status;

  const GroupChoreItem({
    required this.id,
    required this.name,
    required this.status,
  });
  @override
  List<Object?> get props => [id, name, status];
}
