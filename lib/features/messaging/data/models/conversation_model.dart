// lib/features/messaging/data/models/conversation_model.dart

class ConversationModel {
  final String ideaId;
  final String ideaTitle;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  const ConversationModel({
    required this.ideaId,
    required this.ideaTitle,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  /// Maps directly from the `get_my_conversations()` RPC response
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      ideaId: json['idea_id'] as String,
      ideaTitle: json['idea_title'] as String? ?? 'Untitled Idea',
      otherUserId: json['other_user_id'] as String,
      otherUserName: json['other_user_name'] as String? ?? 'Unknown',
      otherUserAvatar: json['other_user_avatar'] as String?,
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageAt: DateTime.tryParse(json['last_message_at'] as String? ?? '')
              ?.toLocal() ??
          DateTime.now(),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  bool get hasUnread => unreadCount > 0;
}
