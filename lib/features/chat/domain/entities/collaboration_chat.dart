import 'package:equatable/equatable.dart';

class CollaborationChat extends Equatable {
  final String ideaId;
  final String roomId;
  final String ideaTitle;
  final String partnerName;
  final String partnerAvatar;

  const CollaborationChat({
    required this.ideaId,
    required this.roomId,
    required this.ideaTitle,
    required this.partnerName,
    required this.partnerAvatar,
  });

  @override
  List<Object?> get props => [ideaId, roomId, ideaTitle, partnerName, partnerAvatar];
}
