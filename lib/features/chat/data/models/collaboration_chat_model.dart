import '../../domain/entities/collaboration_chat.dart';

class CollaborationChatModel extends CollaborationChat {
  const CollaborationChatModel({
    required super.ideaId,
    required super.roomId,
    required super.ideaTitle,
    required super.partnerName,
    required super.partnerAvatar,
  });

  factory CollaborationChatModel.fromJson(Map<String, dynamic> json, {required bool isInnovator}) {
    return CollaborationChatModel(
      ideaId: json['idea_id'] as String,
      ideaTitle: json['title'] as String,
      roomId: json['room_id'] as String,
      partnerName: json[isInnovator ? 'collaborator_name' : 'innovator_name'] as String? ?? 'Unknown',
      partnerAvatar: json[isInnovator ? 'collaborator_avatar' : 'innovator_avatar'] as String? ?? '',
    );
  }
}
