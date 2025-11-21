import 'dart:async';
import 'package:dayli_expenses/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser getCurrentUser;
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;

  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required this.getCurrentUser,
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AuthStateChanged>(_onAuthStateChanged);

    // Suscribirse a cambios de autenticación
    _authStateSubscription = getCurrentUser.authStateChanges.listen((user) {
      add(AuthStateChanged(user));
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final user = getCurrentUser();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final user = await signInWithEmail(
        SignInWithEmailParams(
          email: event.email,
          password: event.password,
        ),
      );

      emit(Authenticated(user));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(AuthError(failure: failure));
      // Volver a Unauthenticated después de mostrar error
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final user = await signUpWithEmail(
        SignUpWithEmailParams(
          email: event.email,
          password: event.password,
          firstName: event.firstName,
          lastName: event.lastName,
        ),
      );

      emit(Authenticated(user));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(AuthError(failure: failure));
      // Volver a Unauthenticated después de mostrar error
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final user = await signInWithGoogle(NoParams());

      emit(Authenticated(user));
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(AuthError(failure: failure));
      // Volver a Unauthenticated después de mostrar error
      await Future.delayed(const Duration(milliseconds: 100));
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      await signOut(NoParams());
      emit(const Unauthenticated());
    } catch (error) {
      final failure = ErrorHandler.handleException(error);
      emit(AuthError(failure: failure, isRecoverable: false));
    }
  }

  void _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(const Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
