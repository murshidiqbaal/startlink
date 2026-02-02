import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../domain/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<sb.AuthState> _authStateSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateRoleRequested>(_onAuthUpdateRoleRequested);

    _authStateSubscription = _authRepository.authStateChanges.listen((data) {
      final session = data.session;
      if (session != null) {
        add(AuthStarted());
      } else {
        add(AuthStarted());
      }
    });
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.login(event.email, event.password);
    } on sb.AuthException catch (e) {
      // Check for specific error indicating email confirmation is required
      if (e.message.toLowerCase().contains('email not confirmed')) {
        emit(
          const AuthError(
            message:
                'Please confirm your email before logging in. Check your inbox.',
          ),
        );
      } else {
        emit(AuthError(message: e.message));
      }
    } catch (e) {
      emit(
        const AuthError(message: 'An unexpected error occurred during login'),
      );
    }
  }

  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signup(
        event.email,
        event.password,
        role: event.role,
      );

      // If session is null, it typically means 'Enable Email Confirmations' is ON in Supabase
      // and the user must verify their email before logging in.
      if (response.session == null) {
        emit(AuthSignedUp());
      }
      // If session is NOT null, the stream listener will trigger AuthStarted -> AuthAuthenticated automatically.
    } on sb.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(
        const AuthError(message: 'An unexpected error occurred during signup'),
      );
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authRepository.loginWithGoogle();
      // No emit(AuthAuthenticated) here because authStateChanges stream will trigger it
    } on sb.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthUpdateRoleRequested(
    AuthUpdateRoleRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.updateRole(event.role);
      // We don't need to manually emit AuthAuthenticated here because
      // updating the user triggers the authStateChanges stream,
      // which in turn triggers _onAuthStarted, effectively refreshing the user data.
      // However, to be safe and ensure UI updates immediately if stream is slow:
      final updatedUser = _authRepository.currentUser;
      if (updatedUser != null) {
        emit(AuthAuthenticated(user: updatedUser));
      }
    } on sb.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(const AuthError(message: 'Failed to update role'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
