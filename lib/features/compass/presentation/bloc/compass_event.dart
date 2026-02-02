import 'package:equatable/equatable.dart';

abstract class CompassEvent extends Equatable {
  const CompassEvent();
  @override
  List<Object> get props => [];
}

class LoadCompass extends CompassEvent {
  final String profileId;
  const LoadCompass(this.profileId);
  @override
  List<Object> get props => [profileId];
}

class RefreshCompass extends CompassEvent {
  final String profileId;
  const RefreshCompass(this.profileId);
  @override
  List<Object> get props => [profileId];
}
