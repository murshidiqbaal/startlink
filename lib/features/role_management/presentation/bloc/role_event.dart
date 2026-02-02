import 'package:equatable/equatable.dart';
import 'package:startlink/core/constants/user_role.dart';

abstract class RoleEvent extends Equatable {
  const RoleEvent();
  @override
  List<Object> get props => [];
}

class RoleChanged extends RoleEvent {
  final UserRole newRole;
  const RoleChanged(this.newRole);
  @override
  List<Object> get props => [newRole];
}

class RoleLoaded extends RoleEvent {
  final UserRole role;
  const RoleLoaded(this.role);
}
