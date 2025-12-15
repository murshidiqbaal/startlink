import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> signup(String email, String password, {String? role});
  Future<bool> loginWithGoogle();
  Future<void> logout();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
  Future<void> updateRole(String role);
}
