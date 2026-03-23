import 'package:equatable/equatable.dart';
import 'package:startlink/core/constants/user_role.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';

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
  final ProfileModel baseProfile;

  const ProfileGateBlocked({
    required this.role,
    required this.missingFields,
    required this.completionPercentage,
    required this.baseProfile,
  });

  @override
  List<Object> get props => [
    role,
    missingFields,
    completionPercentage,
    baseProfile,
  ];
}

class ProfileGateError extends ProfileGateState {
  final String message;
  const ProfileGateError(this.message);
  @override
  List<Object> get props => [message];
}
