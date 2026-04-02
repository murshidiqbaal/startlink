import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/mentor_reel.dart';
import '../../../domain/repositories/mentor_reels_repository.dart';

// --- Events ---
abstract class MentorReelsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadReels extends MentorReelsEvent {}

class UploadReel extends MentorReelsEvent {
  final String mentorId;
  final File videoFile;
  final String? caption;

  UploadReel({required this.mentorId, required this.videoFile, this.caption});

  @override
  List<Object?> get props => [mentorId, videoFile, caption];
}

// --- States ---
abstract class MentorReelsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReelsInitial extends MentorReelsState {}
class ReelsLoading extends MentorReelsState {}
class ReelsLoaded extends MentorReelsState {
  final List<MentorReel> reels;
  ReelsLoaded(this.reels);
  @override
  List<Object?> get props => [reels];
}
class ReelUploading extends MentorReelsState {}
class ReelUploaded extends MentorReelsState {}
class ReelsError extends MentorReelsState {
  final String message;
  ReelsError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class MentorReelsBloc extends Bloc<MentorReelsEvent, MentorReelsState> {
  final IMentorReelsRepository _repository;

  MentorReelsBloc(this._repository) : super(ReelsInitial()) {
    on<LoadReels>(_onLoadReels);
    on<UploadReel>(_onUploadReel);
  }

  Future<void> _onLoadReels(LoadReels event, Emitter<MentorReelsState> emit) async {
    emit(ReelsLoading());
    try {
      final reels = await _repository.getReels();
      emit(ReelsLoaded(reels));
    } catch (e) {
      emit(ReelsError(e.toString()));
    }
  }

  Future<void> _onUploadReel(UploadReel event, Emitter<MentorReelsState> emit) async {
    emit(ReelUploading());
    try {
      await _repository.uploadReel(event.mentorId, event.videoFile, event.caption);
      emit(ReelUploaded());
      add(LoadReels()); // Refresh
    } catch (e) {
      emit(ReelsError(e.toString()));
    }
  }
}
