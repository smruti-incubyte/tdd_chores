import 'package:tdd_chores/core/enums/enums.dart';
import 'package:equatable/equatable.dart';

class SingleChoreEntity extends Equatable {
  final String? id;
  final String name;
  final DateTime dateTime;
  final ChoreStatus status;

  const SingleChoreEntity({
    this.id,
    required this.name,
    required this.dateTime,
    required this.status,
  });
  @override
  List<Object?> get props => [id, name, dateTime, status];
}
