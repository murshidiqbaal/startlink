import 'package:equatable/equatable.dart';
import 'package:startlink/core/constants/user_role.dart';

abstract class ProfileGateState extends Equatable {
  const ProfileGateState();
  @override
  List<Object> get props => [];
}

class ProfileGateInitial extends ProfileGateState {}

class ProfileGateLoading extends ProfileGateState {}

class ProfileGateAllowed extends ProfileGateState {
  final UserRole role;
  const ProfileGateAllowed(this.role);
  @override
  List<Object> get props => [role];
}

class ProfileGateBlocked extends ProfileGateState {
  final UserRole role;
  final List<String> missingFields;
  final int completionPercentage;

  const ProfileGateBlocked({
    required this.role,
    required this.missingFields,
    required this.completionPercentage,
  });

  @override
  List<Object> get props => [role, missingFields, completionPercentage];
}

class ProfileGateError extends ProfileGateState {
  final String message;
  const ProfileGateError(this.message);
  @override
  List<Object> get props => [message];
}
