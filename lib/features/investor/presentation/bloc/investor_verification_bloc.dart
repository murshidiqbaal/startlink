import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startlink/core/services/supabase_client.dart';

// Events
abstract class InvestorVerificationEvent extends Equatable {
  const InvestorVerificationEvent();
  @override
  List<Object?> get props => [];
}

class CheckInvestorVerification extends InvestorVerificationEvent {
  final String userId;
  const CheckInvestorVerification(this.userId);
  @override
  List<Object?> get props => [userId];
}

// States
abstract class InvestorVerificationState extends Equatable {
  const InvestorVerificationState();
  @override
  List<Object?> get props => [];
}

class VerificationInitial extends InvestorVerificationState {}
class VerificationChecking extends InvestorVerificationState {}
class VerificationStatusLoaded extends InvestorVerificationState {
  final String status; // 'pending', 'approved', 'rejected', 'not_submitted'
  const VerificationStatusLoaded(this.status);
  
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';
  bool get isNotSubmitted => status == 'not_submitted';

  @override
  List<Object?> get props => [status];
}
class VerificationError extends InvestorVerificationState {
  final String message;
  const VerificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class InvestorVerificationBloc extends Bloc<InvestorVerificationEvent, InvestorVerificationState> {
  final SupabaseClient _supabase;

  InvestorVerificationBloc({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client,
      super(VerificationInitial()) {
    on<CheckInvestorVerification>(_onCheckVerification);
  }

  Future<void> _onCheckVerification(
    CheckInvestorVerification event,
    Emitter<InvestorVerificationState> emit,
  ) async {
    emit(VerificationChecking());
    try {
      final response = await _supabase
          .from('user_verifications')
          .select('*')
          .eq('profile_id', event.userId)
          .eq('role', 'investor')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response == null) {
        emit(const VerificationStatusLoaded('not_submitted'));
      } else {
        emit(VerificationStatusLoaded(response['status']));
      }
    } catch (e) {
      emit(VerificationError(e.toString()));
    }
  }
}
