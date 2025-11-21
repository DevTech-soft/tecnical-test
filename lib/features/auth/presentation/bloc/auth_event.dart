part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event para verificar el estado de autenticación
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event para login con email/password
class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event para registro con email/password
class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName];
}

/// Event para login con Google
class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// Event para cerrar sesión
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event cuando el estado de auth cambia
class AuthStateChanged extends AuthEvent {
  final User? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
