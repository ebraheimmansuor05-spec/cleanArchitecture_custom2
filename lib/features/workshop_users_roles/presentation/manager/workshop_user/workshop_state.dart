import 'package:equatable/equatable.dart';

import '../../../domain/entities/workshop_entity.dart';

abstract class WorkshopState extends Equatable {
  const WorkshopState();

  @override
  List<Object?> get props => [];
}

class WorkshopInitial extends WorkshopState {}

class WorkshopLoading extends WorkshopState {}

class WorkshopCreated extends WorkshopState {
  final WorkshopEntity workshop;

  const WorkshopCreated(this.workshop);

  @override
  List<Object?> get props => [workshop];
}

class WorkshopLoaded extends WorkshopState {
  final WorkshopEntity workshop;

  const WorkshopLoaded(this.workshop);

  @override
  List<Object?> get props => [workshop];
}

class WorkshopError extends WorkshopState {
  final String message;

  const WorkshopError(this.message);

  @override
  List<Object?> get props => [message];
}