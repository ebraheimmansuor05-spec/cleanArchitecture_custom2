// lib/features/authentication/presentation/manager/authentication_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user_entity.dart';
import 'authentication_cubit.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {
  final AuthenticationAction action;

  const AuthenticationLoading(this.action);

  @override
  List<Object?> get props => [action];
}

class AuthenticationSuccess extends AuthenticationState {
  final AuthenticationAction action;
  final AuthUserEntity? user;

  const AuthenticationSuccess(
    this.action, {
    this.user,
  });

  @override
  List<Object?> get props => [action, user];
}

class AuthenticationFailureState extends AuthenticationState {
  final AuthenticationAction action;
  final AuthErrorCode errorCode;
  final Map<AuthField, AuthValidationCode> fieldErrors;

  const AuthenticationFailureState({
    required this.action,
    required this.errorCode,
    this.fieldErrors = const {},
  });

  @override
  List<Object?> get props => [action, errorCode, fieldErrors];
}