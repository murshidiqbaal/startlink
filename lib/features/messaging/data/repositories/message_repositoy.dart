// lib/features/messaging/data/repositories/message_repository.dart

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessageRepository {
  final SupabaseClient _client;

  MessageRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String get _me => _client.auth.currentUser!.id;

  // ── Conversations ────────────────────────────────────────────────────────────

  /// Calls the `get_my_conversations` Postgres RPC.
  /// Returns one entry per unique (idea_id + other_user) pair, sorted by
  /// most recent message first.
  Future<List<ConversationModel>> getConversations() async {
    final data = await _client.rpc('get_my_conversations') as List;
    return data
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Messages ─────────────────────────────────────────────────────────────────

  /// Fetches all messages between the current user and [otherUserId]
  /// scoped to a specific [ideaId], ordered oldest → newest.
  Future<List<MessageModel>> getMessages({
    required String ideaId,
    required String otherUserId,
  }) async {
    final data =
        await _client
                .from('messages')
                .select()
                .eq('idea_id', ideaId)
                .or(
                  // Messages where I sent → them, OR they sent → me
                  'and(sender_id.eq.$_me,receiver_id.eq.$otherUserId),'
                  'and(sender_id.eq.$otherUserId,receiver_id.eq.$_me)',
                )
                .order('created_at', ascending: true)
            as List;

    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Returns a broadcast stream of messages for a conversation.
  /// Emits the full message list on open, then re-emits whenever a new
  /// INSERT arrives via Supabase Realtime.
  Stream<List<MessageModel>> watchMessages({
    required String ideaId,
    required String otherUserId,
  }) {
    final controller = StreamController<List<MessageModel>>.broadcast();

    // Emit the initial batch immediately
    getMessages(ideaId: ideaId, otherUserId: otherUserId).then(
      (msgs) {
        if (!controller.isClosed) controller.add(msgs);
      },
      onError: (e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    // Subscribe to realtime INSERTs on this idea's messages
    final channel = _client
        .channel('chat_${ideaId}_$_me')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'idea_id',
            value: ideaId,
          ),
          callback: (payload) async {
            // Filter for only this conversation pair
            final rec = payload.newRecord as Map<String, dynamic>;
            final senderId = rec['sender_id'] as String?;
            final receiverId = rec['receiver_id'] as String?;

            final isRelevant =
                (senderId == _me && receiverId == otherUserId) ||
                (senderId == otherUserId && receiverId == _me);

            if (isRelevant && !controller.isClosed) {
              // Re-fetch the full list to keep ordering consistent
              final msgs = await getMessages(
                ideaId: ideaId,
                otherUserId: otherUserId,
              );
              if (!controller.isClosed) controller.add(msgs);
            }
          },
        )
        .subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(channel);
      await controller.close();
    };

    return controller.stream;
  }

  /// Inserts a new message and returns the persisted record.
  Future<MessageModel> sendMessage({
    required String ideaId,
    required String receiverId,
    required String content,
  }) async {
    final data = await _client
        .from('messages')
        .insert({
          'sender_id': _me,
          'receiver_id': receiverId,
          'idea_id': ideaId,
          'content': content.trim(),
        })
        .select()
        .single();

    return MessageModel.fromJson(data as Map<String, dynamic>);
  }

  /// Marks all unread messages FROM [otherUserId] in [ideaId] as read.
  Future<void> markAsRead({
    required String ideaId,
    required String otherUserId,
  }) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('idea_id', ideaId)
        .eq('sender_id', otherUserId)
        .eq('receiver_id', _me)
        .eq('is_read', false);
  }
}
