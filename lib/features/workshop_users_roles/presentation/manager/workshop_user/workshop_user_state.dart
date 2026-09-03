import 'package:equatable/equatable.dart';

import '../../../domain/entities/workshop_user_entity.dart';

abstract class WorkshopUserState extends Equatable {
  const WorkshopUserState();

  @override
  List<Object?> get props => [];
}

class WorkshopUserInitial extends WorkshopUserState {}

class WorkshopUserLoading extends WorkshopUserState {}

class WorkshopUserLoaded extends WorkshopUserState {
 final List<WorkshopUserEntity> users;

  const WorkshopUserLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class WorkshopUserError extends WorkshopUserState {
  final String message;

  const WorkshopUserError(this.message);

  @override
  List<Object?> get props => [message];
}
