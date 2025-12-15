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
      final event = data.event;
      if (event == sb.AuthChangeEvent.signedIn ||
          event == sb.AuthChangeEvent.userUpdated ||
          event == sb.AuthChangeEvent.tokenRefreshed) {
        // Explicitly check for session to be safe
        if (data.session != null) {
          add(AuthStarted());
        }
      } else if (event == sb.AuthChangeEvent.signedOut) {
        add(AuthLogoutRequested());
      }
    });
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    // Check if user is present AND not just a partial object from signup
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
      final response = await _authRepository.login(event.email, event.password);
      if (response.user != null && response.session == null) {
        // User exists but no session -> Likely email not confirmed
        emit(AuthError(message: 'Please confirm your email address.'));
      }
    } on sb.AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        emit(AuthError(message: 'Please confirm your email address.'));
      } else {
        emit(AuthError(message: e.message));
      }
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
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
      // If Supabase returns a session, auto-login is active
      if (response.session != null) {
        emit(AuthAuthenticated(user: response.user!));
      } else {
        // If no session, email confirmation is likely required
        emit(AuthSignedUp());
      }
    } on sb.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
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
