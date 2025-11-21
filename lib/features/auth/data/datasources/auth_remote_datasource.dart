import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  /// Get current user
  firebase_auth.User? getCurrentUser();

  /// Sign in with email and password
  Future<firebase_auth.User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<firebase_auth.User> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<firebase_auth.User> signInWithGoogle();

  /// Sign out
  Future<void> signOut();

  /// Get auth state stream
  Stream<firebase_auth.User?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  firebase_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<firebase_auth.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException(
          message: 'Error al iniciar sesión',
          code: 'SIGN_IN_ERROR',
        );
      }

      return credential.user!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: ${e.toString()}',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  @override
  Future<firebase_auth.User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException(
          message: 'Error al crear cuenta',
          code: 'SIGN_UP_ERROR',
        );
      }

      return credential.user!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado: ${e.toString()}',
        code: 'UNEXPECTED_ERROR',
      );
    }
  }

  @override
  Future<firebase_auth.User> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        throw ServerException(
          message: 'Inicio de sesión cancelado',
          code: 'SIGN_IN_CANCELLED',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw ServerException(
          message: 'Error al iniciar sesión con Google',
          code: 'GOOGLE_SIGN_IN_ERROR',
        );
      }

      return userCredential.user!;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Error al iniciar sesión con Google: ${e.toString()}',
        code: 'GOOGLE_SIGN_IN_ERROR',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw ServerException(
        message: 'Error al cerrar sesión: ${e.toString()}',
        code: 'SIGN_OUT_ERROR',
      );
    }
  }

  @override
  Stream<firebase_auth.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  /// Helper to handle Firebase Auth exceptions
  ServerException _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return ServerException(
          message: 'No existe una cuenta con este email',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return ServerException(
          message: 'Contraseña incorrecta',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return ServerException(
          message: 'Este email ya está en uso',
          code: 'EMAIL_IN_USE',
        );
      case 'weak-password':
        return ServerException(
          message: 'La contraseña es muy débil (mínimo 6 caracteres)',
          code: 'WEAK_PASSWORD',
        );
      case 'invalid-email':
        return ServerException(
          message: 'Email inválido',
          code: 'INVALID_EMAIL',
        );
      case 'user-disabled':
        return ServerException(
          message: 'Esta cuenta ha sido deshabilitada',
          code: 'USER_DISABLED',
        );
      case 'too-many-requests':
        return ServerException(
          message: 'Demasiados intentos. Intenta más tarde',
          code: 'TOO_MANY_REQUESTS',
        );
      case 'operation-not-allowed':
        return ServerException(
          message: 'Operación no permitida',
          code: 'OPERATION_NOT_ALLOWED',
        );
      case 'network-request-failed':
        return ServerException.noConnection();
      default:
        return ServerException(
          message: 'Error de autenticación: ${e.message}',
          code: e.code.toUpperCase(),
        );
    }
  }
}
