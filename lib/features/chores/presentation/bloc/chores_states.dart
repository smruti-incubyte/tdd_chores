import 'package:equatable/equatable.dart';

abstract class ChoresState extends Equatable {
  const ChoresState();

  @override
  List<Object?> get props => [];
}

class ChoresInitial extends ChoresState {}
