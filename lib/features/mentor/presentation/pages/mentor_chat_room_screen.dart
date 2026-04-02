import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import '../../domain/entities/mentor_chat.dart';
import '../bloc/chat/mentor_chat_bloc.dart';

class MentorChatRoomScreen extends StatefulWidget {
  final MentorChat chat;
  const MentorChatRoomScreen({super.key, required this.chat});

  @override
  State<MentorChatRoomScreen> createState() => _MentorChatRoomScreenState();
}

class _MentorChatRoomScreenState extends State<MentorChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MentorChatBloc>().add(LoadMessages(widget.chat.id));
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthRepository>().currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chat.userName ?? 'User'),
            Text(
              widget.chat.ideaTitle ?? 'Discussion',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<MentorChatBloc, MentorChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MessagesLoaded) {
                  return ListView.builder(
                    reverse: true, // Show most recent messages at the bottom
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[state.messages.length - 1 - index];
                      final isMe = message.senderId == currentUserId;
                      return _MessageBubble(message: message, isMe: isMe);
                    },
                  );
                } else if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    final currentUserId = context.read<AuthRepository>().currentUser?.id;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty && currentUserId != null) {
                context.read<MentorChatBloc>().add(
                  SendMessage(
                    chatId: widget.chat.id,
                    senderId: currentUserId,
                    content: _controller.text,
                  ),
                );
                _controller.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MentorMessage message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[300] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
