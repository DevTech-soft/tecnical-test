import '../entities/user.dart';

abstract class AuthRepository {
  /// Get current authenticated user
  User? getCurrentUser();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;

  /// Sign in with email and password
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign out
  Future<void> signOut();
}
