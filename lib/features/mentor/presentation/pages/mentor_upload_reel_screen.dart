import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import '../bloc/reels/mentor_reels_bloc.dart';
import '../widgets/reels_video_player.dart';

class MentorUploadReelScreen extends StatefulWidget {
  const MentorUploadReelScreen({super.key});

  @override
  State<MentorUploadReelScreen> createState() => _MentorUploadReelScreenState();
}

class _MentorUploadReelScreenState extends State<MentorUploadReelScreen> {
  File? _videoFile;
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _videoFile = File(video.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Learning Reel'),
      ),
      body: BlocListener<MentorReelsBloc, MentorReelsState>(
        listener: (context, state) {
          if (state is ReelUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reel uploaded successfully!')),
            );
            Navigator.pop(context);
          } else if (state is ReelsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _videoFile != null
                      ? ReelsVideoPlayer(videoUrl: _videoFile!.path) // Local file path works for VideoPlayer
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_library, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text('Tap to select a video', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _captionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Caption (Optional)',
                  hintText: 'Share some knowledge...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<MentorReelsBloc, MentorReelsState>(
                builder: (context, state) {
                  final uploading = state is ReelUploading;
                  return ElevatedButton(
                    onPressed: (uploading || _videoFile == null)
                        ? null
                        : () {
                            final mentorId = context.read<AuthRepository>().currentUser?.id;
                            if (mentorId != null) {
                              context.read<MentorReelsBloc>().add(
                                    UploadReel(
                                      mentorId: mentorId,
                                      videoFile: _videoFile!,
                                      caption: _captionController.text,
                                    ),
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: uploading
                        ? const CircularProgressIndicator()
                        : const Text('Publish Reel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
