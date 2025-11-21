import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserRemoteDataSource userRemoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.userRemoteDataSource,
  });

  @override
  User? getCurrentUser() {
    final firebaseUser = remoteDataSource.getCurrentUser();
    if (firebaseUser == null) return null;
    return UserModel.fromFirebaseUser(firebaseUser).toEntity();
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebaseUser(firebaseUser).toEntity();
    });
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final firebaseUser = await remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );

    final userModel = UserModel.fromFirebaseUser(firebaseUser);

    // Guardar/actualizar usuario en Firestore
    await userRemoteDataSource.saveUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final firebaseUser = await remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
    );

    final userModel = UserModel.fromFirebaseUser(firebaseUser);

    // Guardar usuario nuevo en Firestore
    await userRemoteDataSource.saveUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<User> signInWithGoogle() async {
    final firebaseUser = await remoteDataSource.signInWithGoogle();

    final userModel = UserModel.fromFirebaseUser(firebaseUser);

    // Guardar/actualizar usuario en Firestore
    await userRemoteDataSource.saveUser(userModel);

    return userModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
}
