import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import '../bloc/reels/mentor_reels_bloc.dart';

class MentorManagementScreen extends StatefulWidget {
  const MentorManagementScreen({super.key});

  @override
  State<MentorManagementScreen> createState() => _MentorManagementScreenState();
}

class _MentorManagementScreenState extends State<MentorManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MentorReelsBloc>().add(LoadReels());
  }

  @override
  Widget build(BuildContext context) {
    final currentMentorId = context.read<AuthRepository>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Management'),
      ),
      body: BlocBuilder<MentorReelsBloc, MentorReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReelsLoaded) {
            final myReels = state.reels.where((r) => r.mentorId == currentMentorId).toList();
            
            if (myReels.isEmpty) {
              return const Center(child: Text('You haven\'t uploaded any reels yet.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Your Learning Reels',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[800]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: DataTable(
                          columnSpacing: 12,
                          headingRowColor: WidgetStateProperty.all(Colors.grey[900]),
                          columns: const [
                            DataColumn(label: Text('Caption')),
                            DataColumn(label: Text('Created')),
                            DataColumn(label: Text('Link')),
                          ],
                          rows: myReels.map((reel) {
                            return DataRow(cells: [
                              DataCell(
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    reel.caption ?? 'No caption',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                 Text(
                                  '${reel.createdAt.day}/${reel.createdAt.month}/${reel.createdAt.year}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.link, size: 18),
                                  onPressed: () {
                                     // Logic to copy link or preview
                                     ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Video link copied!')),
                                    );
                                  },
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ReelsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.square(dimension: 1);
        },
      ),
    );
  }
}
