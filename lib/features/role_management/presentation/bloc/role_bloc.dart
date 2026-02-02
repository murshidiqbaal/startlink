import 'package:bloc/bloc.dart';
import 'package:startlink/features/role_management/presentation/bloc/role_event.dart';
import 'package:startlink/features/role_management/presentation/bloc/role_state.dart';

class RoleBloc extends Bloc<RoleEvent, RoleState> {
  RoleBloc() : super(const RoleInitial()) {
    on<RoleChanged>(_onRoleChanged);
  }

  void _onRoleChanged(RoleChanged event, Emitter<RoleState> emit) {
    emit(RoleSuccess(event.newRole));
  }
}
