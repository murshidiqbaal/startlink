import 'package:equatable/equatable.dart';
import 'package:startlink/core/constants/user_role.dart';

abstract class ProfileGateEvent extends Equatable {
  const ProfileGateEvent();
  @override
  List<Object> get props => [];
}

class CheckProfileCompliance extends ProfileGateEvent {
  final UserRole role;
  final String userId;
  const CheckProfileCompliance({required this.role, required this.userId});
  @override
  List<Object> get props => [role, userId];
}
