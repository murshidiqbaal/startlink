import 'package:flutter/foundation.dart';
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
      // 1. Sync to public profiles table first (this is critical for UI and RLS)
      try {
        await _supabase
            .from('profiles')
            .update({'role': role})
            .eq('id', user.id);
      } catch (e) {
        debugPrint('AuthRemoteSource: Error updating profiles table: $e');
        // We continue even if profile update fails, as the Auth metadata is the source of truth for the JWT
      }
    }

    // 2. Refresh session if it's stale or if we suspect it might be the cause of 403
    try {
      final session = _supabase.auth.currentSession;
      if (session != null && session.isExpired) {
        debugPrint('AuthRemoteSource: Session expired, refreshing before update...');
        await _supabase.auth.refreshSession();
      }
    } catch (e) {
      debugPrint('AuthRemoteSource: Failed to pre-refresh session: $e');
    }

    // 3. Update Auth Metadata (this refreshes the JWT)
    try {
      return await _supabase.auth.updateUser(
        UserAttributes(data: {'role': role}),
      );
    } on AuthException catch (e) {
      // 4. Handle "session_not_found" specifically
      if (e.statusCode == '403' || e.message.contains('session_not_found')) {
        debugPrint('AuthRemoteSource: Session not found (403), attempting recovery refresh...');
        try {
          await _supabase.auth.refreshSession();
          // Retry once after refresh
          return await _supabase.auth.updateUser(
            UserAttributes(data: {'role': role}),
          );
        } catch (refreshError) {
          debugPrint('AuthRemoteSource: Recovery refresh failed: $refreshError');
          rethrow; // If refresh fails, we can't recover
        }
      }
      rethrow;
    } catch (e) {
      debugPrint('AuthRemoteSource: Unexpected error in updateRole: $e');
      rethrow;
    }
  }
}
