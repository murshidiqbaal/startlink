import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/auth_remote_source.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthResponse> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<AuthResponse> signup(String email, String password, {String? role}) {
    return remoteDataSource.signup(
      email,
      password,
      data: role != null ? {'role': role} : null,
    );
  }

  @override
  Future<bool> loginWithGoogle() {
    return remoteDataSource.loginWithGoogle();
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  Stream<AuthState> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<void> updateRole(String role) {
    return remoteDataSource.updateRole(role);
  }
}
