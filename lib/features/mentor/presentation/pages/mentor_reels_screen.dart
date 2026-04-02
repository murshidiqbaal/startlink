import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import '../bloc/reels/mentor_reels_bloc.dart';
import '../widgets/reels_video_player.dart';
import 'mentor_upload_reel_screen.dart';

class MentorReelsScreen extends StatefulWidget {
  const MentorReelsScreen({super.key});

  @override
  State<MentorReelsScreen> createState() => _MentorReelsScreenState();
}

class _MentorReelsScreenState extends State<MentorReelsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MentorReelsBloc>().add(LoadReels());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<MentorReelsBloc, MentorReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReelsLoaded) {
            if (state.reels.isEmpty) {
              return const Center(child: Text('No reels yet.', style: TextStyle(color: Colors.white)));
            }
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.reels.length,
              itemBuilder: (context, index) {
                final reel = state.reels[index];
                return Stack(
                  children: [
                    ReelsVideoPlayer(videoUrl: reel.videoUrl),
                    _buildOverlay(reel),
                  ],
                );
              },
            );
          } else if (state is ReelsError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.white)));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: context.watch<AuthRepository>().currentUser != null &&
              context.watch<AuthRepository>().currentUser?.userMetadata?['role'] == 'Mentor'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MentorUploadReelScreen()),
                ).then((_) => context.read<MentorReelsBloc>().add(LoadReels()));
              },
              child: const Icon(Icons.add_a_photo),
            )
          : null,
    );
  }

  Widget _buildOverlay(reel) {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: reel.mentorAvatarUrl != null ? NetworkImage(reel.mentorAvatarUrl!) : null,
                child: reel.mentorAvatarUrl == null ? const Icon(Icons.person, size: 20) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reel.mentorName ?? 'Mentor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reel.caption ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

}
