import 'package:equatable/equatable.dart';
import 'package:startlink/core/constants/user_role.dart';

abstract class RoleState extends Equatable {
  final UserRole activeRole;
  const RoleState(this.activeRole);

  @override
  List<Object> get props => [activeRole];
}

class RoleInitial extends RoleState {
  const RoleInitial() : super(UserRole.innovator);
}

class RoleSuccess extends RoleState {
  const RoleSuccess(super.activeRole);
}
