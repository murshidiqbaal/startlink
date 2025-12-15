import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  late final StreamSubscription<sb.AuthState> _authStateSubscription;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    _authStateSubscription = _authService.authStateChanges.listen((data) {
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
    final user = _authService.currentUser;
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
      await _authService.signInWithEmail(event.email, event.password);
    } on sb.AuthException catch (e) {
      emit(AuthError(message: e.message));
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
      await _authService.signUpWithEmail(
        event.email,
        event.password,
        data: {'role': event.role},
      );
      emit(AuthSignedUp());
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
      await _authService.signInWithGoogle();
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
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
