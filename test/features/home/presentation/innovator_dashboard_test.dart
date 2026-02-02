import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/compass/domain/entities/compass_recommendation.dart';
import 'package:startlink/features/compass/domain/repositories/compass_repository.dart';
import 'package:startlink/features/home/presentation/innovator_dashboard.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Manual Mocks --- //

class FakeIdeaBloc extends Bloc<IdeaEvent, IdeaState> implements IdeaBloc {
  FakeIdeaBloc() : super(IdeaInitial()) {
    on<RefreshIdeas>((event, emit) {});
  }
  void setState(IdeaState state) => emit(state);
}

class FakeProfileBloc extends Bloc<ProfileEvent, ProfileState>
    implements ProfileBloc {
  FakeProfileBloc() : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) {});
  }
  void setState(ProfileState state) => emit(state);
}

class FakeCompassRepository implements CompassRepository {
  @override
  Future<List<CompassRecommendation>> getRecommendations(
    String profileId,
  ) async => [];

  @override
  Future<void> recalculateRecommendations(
    ProfileModel profile, {
    List<Idea>? ideas,
  }) async {}
}

class FakeAuthRepository implements AuthRepository {
  @override
  User? get currentUser => const User(
    id: 'test_user_id',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: '2024-01-01T00:00:00.000Z',
  );

  @override
  Stream<AuthState> get authStateChanges => Stream.empty();

  @override
  Future<AuthResponse> login(String email, String password) async =>
      AuthResponse();

  @override
  Future<bool> loginWithGoogle() async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<AuthResponse> signup(
    String email,
    String password, {
    String? role,
  }) async => AuthResponse();

  @override
  Future<void> updateRole(String role) async {}
}

void main() {
  late FakeIdeaBloc ideaBloc;
  late FakeProfileBloc profileBloc;
  late FakeCompassRepository compassRepo;
  late FakeAuthRepository authRepo;

  setUp(() {
    ideaBloc = FakeIdeaBloc();
    profileBloc = FakeProfileBloc();
    compassRepo = FakeCompassRepository();
    authRepo = FakeAuthRepository();
  });

  tearDown(() {
    ideaBloc.close();
    profileBloc.close();
  });

  testWidgets('InnovatorDashboard renders correctly with initial states', (
    WidgetTester tester,
  ) async {
    // Arrange
    ideaBloc.setState(IdeaLoaded(const []));
    profileBloc.setState(
      ProfileLoaded(
        const ProfileModel(
          id: '123',
          fullName: 'Test User',
          profileCompletion: 80,
        ),
      ),
    );

    // Act
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>.value(value: authRepo),
          RepositoryProvider<CompassRepository>.value(value: compassRepo),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<IdeaBloc>.value(value: ideaBloc),
            BlocProvider<ProfileBloc>.value(value: profileBloc),
          ],
          child: const MaterialApp(home: InnovatorDashboard()),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Allow animations/async loading to settle

    // Assert
    expect(find.text('Innovator'), findsOneWidget); // Welcome message
    expect(find.text('TU'), findsOneWidget); // Initials
    expect(find.text('Post New Idea'), findsOneWidget);
    expect(find.text('Total Ideas'), findsOneWidget);
  });
}
