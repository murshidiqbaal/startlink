import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/home/presentation/bloc/investor_home_bloc.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/investor/domain/repositories/interest_repository.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_interest_bloc.dart';
import 'package:startlink/features/investor/presentation/pages/investor_idea_detail_screen.dart';
import 'package:startlink/features/investor/presentation/widgets/investor_idea_card.dart';
import 'package:startlink/features/profile/presentation/investor_profile_screen.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({super.key});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InvestorHome(),
    const InvestorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: RoleAwareNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class InvestorHome extends StatelessWidget {
  const InvestorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              InvestorHomeBloc(ideaRepository: context.read<IdeaRepository>())
                ..add(FetchInvestorFeed()),
        ),
        BlocProvider(
          create: (context) =>
              InvestorInterestBloc(
                repository: context.read<InterestRepository>(),
              )..add(
                FetchInterests(
                  context.read<AuthRepository>().currentUser?.id ?? '',
                ),
              ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Investor Hub'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          ],
        ),
        body: Column(
          children: [
            // Filter Chips (Static for now, can be dynamic later)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(context, 'All'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'FinTech'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'HealthTech'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'AI'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Pre-Seed'),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<InvestorHomeBloc, InvestorHomeState>(
                builder: (context, homeState) {
                  return BlocBuilder<
                    InvestorInterestBloc,
                    InvestorInterestState
                  >(
                    builder: (context, interestState) {
                      if (homeState is InvestorHomeLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (homeState is InvestorHomeLoaded) {
                        if (homeState.ideas.isEmpty) {
                          return const Center(
                            child: Text('No investment opportunities found.'),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            context.read<InvestorHomeBloc>().add(
                              FetchInvestorFeed(),
                            );
                            final uid = context
                                .read<AuthRepository>()
                                .currentUser
                                ?.id;
                            if (uid != null) {
                              context.read<InvestorInterestBloc>().add(
                                FetchInterests(uid),
                              );
                            }
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: homeState.ideas.length,
                            itemBuilder: (context, index) {
                              final idea = homeState.ideas[index];
                              // Logic to check boosting or verified can be enhanced if data models updated
                              // Currently assumes standard idea model.

                              bool isBookmarked = false;
                              bool isInterested = false;
                              if (interestState is InvestorInterestLoaded) {
                                isBookmarked = interestState.isBookmarked(
                                  idea.id,
                                );
                                isInterested = interestState.isInterested(
                                  idea.id,
                                );
                              }

                              return InvestorIdeaCard(
                                title: idea.title,
                                aiSummary: idea.aiSummary,
                                stage: idea.currentStage,
                                targetMarket: idea.targetMarket,
                                skills: idea.tags,
                                isBoosted:
                                    idea.id == 'boosted' ||
                                    idea.viewCount >
                                        100, // Placeholder per prior logic comment
                                isVerified: idea.isVerified,
                                isBookmarked: isBookmarked,
                                isInterested: isInterested,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          InvestorIdeaDetailScreen(idea: idea),
                                    ),
                                  );
                                },
                                onBookmark: () {
                                  final uid = context
                                      .read<AuthRepository>()
                                      .currentUser
                                      ?.id;
                                  if (uid != null) {
                                    context.read<InvestorInterestBloc>().add(
                                      BookmarkIdea(
                                        ideaId: idea.id,
                                        investorId: uid,
                                      ),
                                    );
                                  }
                                },
                                onExpressInterest: () {
                                  final uid = context
                                      .read<AuthRepository>()
                                      .currentUser
                                      ?.id;
                                  if (uid != null) {
                                    context.read<InvestorInterestBloc>().add(
                                      ExpressInterest(
                                        ideaId: idea.id,
                                        investorId: uid,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        );
                      } else if (homeState is InvestorHomeError) {
                        return Center(child: Text(homeState.message));
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}
