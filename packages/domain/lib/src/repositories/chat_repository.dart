import 'package:domain/src/entities/chat_ban.dart';
import 'package:domain/src/entities/chat_ban_page.dart';
import 'package:domain/src/entities/chat_conversation_page.dart';
import 'package:domain/src/entities/chat_message.dart';
import 'package:domain/src/entities/chat_message_page.dart';
import 'package:domain/src/entities/chat_reaction.dart';
import 'package:domain/src/entities/chat_realtime_event.dart';
import 'package:domain/src/repositories/chat_realtime_handle.dart';

/// Repository interface for event-scoped chat.
abstract interface class ChatRepository {
  /// Subscribes to multiplexed chat topics and delivers [ChatRealtimeEvent]s.
  ///
  /// Call [ChatRealtimeHandle.cancel] when leaving chat scope.
  ChatRealtimeHandle connectChatRealtime({
    required String eventID,
    required List<String> topics,
    required void Function(ChatRealtimeEvent event) onEvent,
    void Function(Object error)? onError,
  });

  Future<ChatMessagePage> getGeneralMessages({
    required String eventID,
    int? limit,
    String? cursor,
  });

  Future<ChatMessage> sendGeneralMessage({
    required String eventID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  });

  Future<void> deleteMessage({
    required String eventID,
    required String messageID,
  });

  Future<List<ChatReaction>> setMessageReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  });

  Future<List<ChatReaction>> removeMessageReaction({
    required String eventID,
    required String messageID,
  });

  Future<ChatConversationPage> getDmConversations({
    required String eventID,
    int? limit,
    String? cursor,
  });

  Future<ChatMessagePage> getDmMessages({
    required String eventID,
    required String recipientUserID,
    int? limit,
    String? cursor,
  });

  Future<ChatMessage> sendDmMessage({
    required String eventID,
    required String recipientUserID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  });

  Future<ChatMessagePage> getOrganizerMessages({
    required String eventID,
    String? cursor,
    int? limit,
  });

  Future<ChatMessage> sendOrganizerMessage({
    required String eventID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  });

  Future<void> deleteOrganizerMessage({
    required String eventID,
    required String messageID,
  });

  Future<List<ChatReaction>> setOrganizerMessageReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  });

  Future<List<ChatReaction>> removeOrganizerMessageReaction({
    required String eventID,
    required String messageID,
  });

  Future<void> deleteGeneralMessageAsOrganizer({
    required String eventID,
    required String messageID,
  });

  Future<ChatBan> banChatUser({
    required String eventID,
    required String userID,
  });

  Future<void> unbanChatUser({
    required String eventID,
    required String userID,
  });

  Future<ChatBanPage> listChatBans({
    required String eventID,
    int? page,
    int? pageSize,
  });
}
