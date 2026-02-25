import 'package:equatable/equatable.dart';

abstract class ChoresEvent extends Equatable {
  const ChoresEvent();

  @override
  List<Object?> get props => [];
}

class GetSingleChoresEvent extends ChoresEvent {}
