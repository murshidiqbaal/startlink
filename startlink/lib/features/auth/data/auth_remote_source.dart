import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_client.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> signup(
    String email,
    String password, {
    Map<String, dynamic>? data,
  });
  Future<bool> loginWithGoogle();
  Future<void> logout();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;
  Future<UserResponse> updateRole(String role);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _supabase = SupabaseService.client;

  @override
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signup(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  @override
  Future<bool> loginWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.startlink://login-callback/',
    );
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  Future<UserResponse> updateRole(String role) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      // Sync to public profiles table
      try {
        await _supabase
            .from('profiles')
            .update({'role': role})
            .eq('id', user.id);
      } catch (e) {
        // Fail silently or log, but don't block metadata update if profile entry is missing
        // (though it shouldn't be if triggers worked)
        print('Error updating profiles table: $e');
      }
    }

    return await _supabase.auth.updateUser(
      UserAttributes(data: {'role': role}),
    );
  }
}
