part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - verificando autenticación
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga (login/registro en proceso)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Usuario autenticado
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Usuario no autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error de autenticación
class AuthError extends AuthState {
  final Failure failure;
  final bool isRecoverable;

  const AuthError({
    required this.failure,
    this.isRecoverable = true,
  });

  /// Mensaje amigable para el usuario
  String get userMessage => ErrorHandler.getUserFriendlyMessage(failure);

  /// Título del error
  String get title => ErrorHandler.getErrorTitle(failure);

  @override
  List<Object?> get props => [failure, isRecoverable];
}
