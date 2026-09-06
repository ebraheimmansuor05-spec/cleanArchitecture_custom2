import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user_entity.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  AuthUserEntity? get user => null;

  bool get isAuthenticated => user != null;

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {
  const SessionInitial();
}

class SessionChecking extends SessionState {
  const SessionChecking();
}

class SessionAuthenticated extends SessionState {
  @override
  final AuthUserEntity user;

  const SessionAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

class SessionLoggingOut extends SessionState {
  @override
  final AuthUserEntity user;

  const SessionLoggingOut(this.user);

  @override
  List<Object?> get props => [user];
}

class SessionFailure extends SessionState {
  final AuthErrorCode errorCode;

  @override
  final AuthUserEntity? user;

  const SessionFailure(this.errorCode, {this.user});

  @override
  List<Object?> get props => [errorCode, user];
}
