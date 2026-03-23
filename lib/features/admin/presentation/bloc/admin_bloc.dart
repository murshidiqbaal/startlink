import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/admin/domain/repositories/admin_repository.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/profile/domain/entities/user_profile.dart';

// Events
abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object> get props => [];
}

class FetchAllUsers extends AdminEvent {}

class BanUser extends AdminEvent {
  final String userId;
  const BanUser(this.userId);
}

class UnbanUser extends AdminEvent {
  final String userId;
  const UnbanUser(this.userId);
}

class FetchAllIdeas extends AdminEvent {}

class DeleteIdea extends AdminEvent {
  final String ideaId;
  const DeleteIdea(this.ideaId);
}

class FlagIdea extends AdminEvent {
  final String ideaId;
  const FlagIdea(this.ideaId);
}

// States
abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminUsersLoaded extends AdminState {
  final List<UserProfile> users;
  const AdminUsersLoaded(this.users);
  @override
  List<Object> get props => [users];
}

class AdminIdeasLoaded extends AdminState {
  final List<Idea> ideas;
  const AdminIdeasLoaded(this.ideas);
  @override
  List<Object> get props => [ideas];
}

class AdminOperationSuccess extends AdminState {
  final String message;
  const AdminOperationSuccess(this.message);
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object> get props => [message];
}

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<FetchAllUsers>((event, emit) async {
      emit(AdminLoading());
      try {
        final users = await repository.getAllUsers();
        emit(AdminUsersLoaded(users));
      } catch (e) {
        emit(AdminError("Failed to fetch users: $e"));
      }
    });

    on<BanUser>((event, emit) async {
      try {
        await repository.banUser(event.userId);
        emit(const AdminOperationSuccess("User banned"));
        add(FetchAllUsers()); // Refresh
      } catch (e) {
        emit(AdminError("Failed to ban user: $e"));
      }
    });

    on<FetchAllIdeas>((event, emit) async {
      emit(AdminLoading());
      try {
        final ideas = await repository.getAllIdeas();
        emit(AdminIdeasLoaded(ideas));
      } catch (e) {
        emit(AdminError("Failed to fetch ideas: $e"));
      }
    });

    on<DeleteIdea>((event, emit) async {
      try {
        await repository.deleteIdea(event.ideaId);
        emit(const AdminOperationSuccess("Idea deleted"));
        add(FetchAllIdeas());
      } catch (e) {
        emit(AdminError("Failed to delete idea: $e"));
      }
    });
  }
}
