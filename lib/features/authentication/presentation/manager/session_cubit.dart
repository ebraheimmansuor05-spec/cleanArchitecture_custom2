import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/auth_user_entity.dart';
import '../../domain/usecases/auth_use_cases.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final CheckSessionUseCase checkSessionUseCase;
  final ObserveAuthStateUseCase observeAuthStateUseCase;
  final LogoutUseCase logoutUseCase;

  StreamSubscription<Either<Failure, AuthUserEntity?>>? _subscription;

  SessionCubit({
    required this.checkSessionUseCase,
    required this.observeAuthStateUseCase,
    required this.logoutUseCase,
  }) : super(const SessionInitial());

  Future<void> start() async {
    if (_subscription != null || state is SessionChecking) return;
    emit(const SessionChecking());

    final initialSession = await checkSessionUseCase();
    if (isClosed) return;
    _applySessionResult(initialSession);

    _subscription = observeAuthStateUseCase().listen(
      _applySessionResult,
      onError: (_) {
        if (!isClosed) {
          emit(SessionFailure(AuthErrorCode.unknown, user: state.user));
        }
      },
    );
  }

  Future<void> logout() async {
    if (state is SessionLoggingOut) return;
    final currentUser = state.user;
    if (currentUser == null) {
      emit(const SessionUnauthenticated());
      return;
    }

    emit(SessionLoggingOut(currentUser));
    final result = await logoutUseCase();
    if (isClosed) return;
    result.fold(
      (failure) => emit(SessionFailure(_errorCode(failure), user: currentUser)),
      (_) => emit(const SessionUnauthenticated()),
    );
  }

  void _applySessionResult(Either<Failure, AuthUserEntity?> result) {
    if (isClosed) return;
    result.fold(
      (failure) => emit(SessionFailure(_errorCode(failure), user: state.user)),
      (user) => emit(
        user == null
            ? const SessionUnauthenticated()
            : SessionAuthenticated(user),
      ),
    );
  }

  AuthErrorCode _errorCode(Failure failure) {
    return failure is AuthenticationFailure
        ? failure.code
        : AuthErrorCode.unknown;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
