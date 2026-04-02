import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import '../bloc/chat/mentor_chat_bloc.dart';
import 'mentor_chat_room_screen.dart';

class MentorChatListScreen extends StatefulWidget {
  const MentorChatListScreen({super.key});

  @override
  State<MentorChatListScreen> createState() => _MentorChatListScreenState();
}

class _MentorChatListScreenState extends State<MentorChatListScreen> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthRepository>().currentUser?.id;
    if (userId != null) {
      context.read<MentorChatBloc>().add(LoadMentorChats(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<MentorChatBloc, MentorChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatsLoaded) {
            if (state.chats.isEmpty) {
              return const Center(child: Text('No active conversations yet.'));
            }
            return ListView.separated(
              itemCount: state.chats.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: chat.userAvatarUrl != null 
                        ? NetworkImage(chat.userAvatarUrl!) 
                        : null,
                    child: chat.userAvatarUrl == null 
                        ? const Icon(Icons.person) 
                        : null,
                  ),
                  title: Text(chat.userName ?? 'User'),
                  subtitle: Text(
                    chat.ideaTitle ?? 'Idea Discussion',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MentorChatRoomScreen(chat: chat),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.square(dimension: 1);
        },
      ),
    );
  }
}
