import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Events
abstract class RoleEvent extends Equatable {
  const RoleEvent();
  @override
  List<Object> get props => [];
}

class RoleStarted extends RoleEvent {}

class RoleChanged extends RoleEvent {
  final String newRole;
  const RoleChanged(this.newRole);
  @override
  List<Object> get props => [newRole];
}

// State
class RoleState extends Equatable {
  final String activeRole;
  const RoleState(this.activeRole);

  @override
  List<Object> get props => [activeRole];
}

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  final Box _settingsBox;
  final dynamic
  _authRepository; // Using dynamic to avoid circular dependency or import issues if I don't import the Repo. Ideally import it.

  RoleBloc({required dynamic authRepository})
    : _authRepository = authRepository,
      _settingsBox = Hive.box('settings'),
      super(const RoleState('Innovator')) {
    on<RoleStarted>(_onStarted);
    on<RoleChanged>(_onChanged);
  }

  void _onStarted(RoleStarted event, Emitter<RoleState> emit) {
    if (_settingsBox.containsKey('active_role')) {
      final cachedRole = _settingsBox.get('active_role');
      emit(RoleState(cachedRole));
    }
  }

  Future<void> _onChanged(RoleChanged event, Emitter<RoleState> emit) async {
    _settingsBox.put('active_role', event.newRole);
    emit(RoleState(event.newRole));
    try {
      await _authRepository.updateRole(event.newRole);
    } catch (e) {
      // Handle error cleanly or retry
      print('Failed to update role in backend: $e');
    }
  }
}
