import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:startlink/core/constants/user_role.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';

// Events
abstract class RoleEvent extends Equatable {
  const RoleEvent();
  @override
  List<Object> get props => [];
}

class RoleStarted extends RoleEvent {}

class RoleChanged extends RoleEvent {
  final UserRole newRole;
  const RoleChanged(this.newRole);
  @override
  List<Object> get props => [newRole];
}

// State
class RoleState extends Equatable {
  final String
  activeRole; // Keeping String for backward compat with UI switching, but logic uses helper
  const RoleState(this.activeRole);

  UserRole get roleEnum => UserRole.fromString(activeRole);

  @override
  List<Object> get props => [activeRole];
}

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final Box _settingsBox;
  final AuthRepository _authRepository;

  RoleBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      _settingsBox = Hive.box('settings'),
      super(const RoleState('Innovator')) {
    on<RoleStarted>(_onStarted);
    on<RoleChanged>(_onChanged);
  }

  void _onStarted(RoleStarted event, Emitter<RoleState> emit) {
    // 1. Try to get role from Supabase User Metadata (Source of Truth)
    try {
      final user = _authRepository.currentUser;
      final serverRole = user?.userMetadata?['role'] as String?;
      if (serverRole != null) {
        _settingsBox.put('active_role', serverRole);
        emit(RoleState(serverRole));
        return;
      }
    } catch (e) {
      // Ignore error and fall back to cache
    }

    // 2. Fallback to local cache
    if (_settingsBox.containsKey('active_role')) {
      final cachedRole = _settingsBox.get('active_role');
      emit(RoleState(cachedRole));
    }
  }

  Future<void> _onChanged(RoleChanged event, Emitter<RoleState> emit) async {
    final roleString = event.newRole.toStringValue;
    _settingsBox.put('active_role', roleString);
    emit(RoleState(roleString));
    try {
      await _authRepository.updateRole(roleString);
    } catch (e) {
      // Handle error cleanly or retry
      debugPrint('Failed to update role in backend: $e');
    }
  }
}
