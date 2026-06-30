import 'dart:async';

import 'package:auth_repository/src/mappers/chat_mapper.dart';
import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

/// Data-layer implementation of [domain.ChatRepository].
final class ChatRepositoryImpl implements domain.ChatRepository {
  ChatRepositoryImpl({
    required api.M3tApiClient apiClient,
  }) : _apiClient = apiClient;

  final api.M3tApiClient _apiClient;

  @override
  domain.ChatRealtimeHandle connectChatRealtime({
    required String eventID,
    required List<String> topics,
    required void Function(domain.ChatRealtimeEvent event) onEvent,
    void Function(Object error)? onError,
  }) {
    final mux = _apiClient.wsMultiplexer;
    final subscriptions = <StreamSubscription<api.WsFrame>>[];

    for (final topic in topics) {
      mux.subscribe(topic);
      final sub = mux.frames(topic).listen(
        (frame) {
          final event = _parseChatRealtimeEvent(frame);
          if (event != null) {
            onEvent(event);
          }
        },
        onError: onError,
      );
      subscriptions.add(sub);
    }

    void cancelAll() {
      for (final sub in subscriptions) {
        unawaited(sub.cancel());
      }
      topics.forEach(mux.unsubscribe);
    }

    return _ChatRealtimeHandleImpl(onCancel: cancelAll);
  }

  @override
  Future<domain.ChatMessagePage> getGeneralMessages({
    required String eventID,
    int? limit,
    String? cursor,
  }) async {
    try {
      final page = await _apiClient.getGeneralChatMessages(
        eventID: eventID,
        limit: limit,
        cursor: cursor,
      );
      return page.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatMessage> sendGeneralMessage({
    required String eventID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  }) async {
    try {
      final message = await _apiClient.sendGeneralChatMessage(
        eventID: eventID,
        body: body,
        clientMsgId: clientMsgId,
        replyToMessageId: replyToMessageId,
      );
      return message.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<void> deleteMessage({
    required String eventID,
    required String messageID,
  }) async {
    try {
      await _apiClient.deleteAttendeeChatMessage(
        eventID: eventID,
        messageID: messageID,
      );
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<List<domain.ChatReaction>> setMessageReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  }) async {
    try {
      final result = await _apiClient.setChatMessageReaction(
        eventID: eventID,
        messageID: messageID,
        emoji: emoji,
      );
      return result.reactionsToDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<List<domain.ChatReaction>> removeMessageReaction({
    required String eventID,
    required String messageID,
  }) async {
    try {
      final result = await _apiClient.removeChatMessageReaction(
        eventID: eventID,
        messageID: messageID,
      );
      return result.reactionsToDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatConversationPage> getDmConversations({
    required String eventID,
    int? limit,
    String? cursor,
  }) async {
    try {
      final page = await _apiClient.getDmConversations(
        eventID: eventID,
        limit: limit,
        cursor: cursor,
      );
      return page.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatMessagePage> getDmMessages({
    required String eventID,
    required String recipientUserID,
    int? limit,
    String? cursor,
  }) async {
    try {
      final page = await _apiClient.getDmMessages(
        eventID: eventID,
        recipientUserID: recipientUserID,
        limit: limit,
        cursor: cursor,
      );
      return page.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatMessage> sendDmMessage({
    required String eventID,
    required String recipientUserID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  }) async {
    try {
      final message = await _apiClient.sendDmMessage(
        eventID: eventID,
        recipientUserID: recipientUserID,
        body: body,
        clientMsgId: clientMsgId,
        replyToMessageId: replyToMessageId,
      );
      return message.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatMessagePage> getOrganizerMessages({
    required String eventID,
    String? cursor,
    int? limit,
  }) async {
    try {
      final page = await _apiClient.getOrganizerChatMessages(
        eventID: eventID,
        cursor: cursor,
        limit: limit,
      );
      return page.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatMessage> sendOrganizerMessage({
    required String eventID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  }) async {
    try {
      final message = await _apiClient.sendOrganizerChatMessage(
        eventID: eventID,
        body: body,
        clientMsgId: clientMsgId,
        replyToMessageId: replyToMessageId,
      );
      return message.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<void> deleteOrganizerMessage({
    required String eventID,
    required String messageID,
  }) async {
    try {
      await _apiClient.deleteOrganizerChatMessage(
        eventID: eventID,
        messageID: messageID,
      );
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<List<domain.ChatReaction>> setOrganizerMessageReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  }) async {
    try {
      final result = await _apiClient.setOrganizerChatReaction(
        eventID: eventID,
        messageID: messageID,
        emoji: emoji,
      );
      return result.reactionsToDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<List<domain.ChatReaction>> removeOrganizerMessageReaction({
    required String eventID,
    required String messageID,
  }) async {
    try {
      final result = await _apiClient.removeOrganizerChatReaction(
        eventID: eventID,
        messageID: messageID,
      );
      return result.reactionsToDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<void> deleteGeneralMessageAsOrganizer({
    required String eventID,
    required String messageID,
  }) async {
    try {
      await _apiClient.deleteGeneralChatMessageAsOrganizer(
        eventID: eventID,
        messageID: messageID,
      );
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatBan> banChatUser({
    required String eventID,
    required String userID,
  }) async {
    try {
      final ban = await _apiClient.banChatUser(
        eventID: eventID,
        userID: userID,
      );
      return ban.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<void> unbanChatUser({
    required String eventID,
    required String userID,
  }) async {
    try {
      await _apiClient.unbanChatUser(eventID: eventID, userID: userID);
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }

  @override
  Future<domain.ChatBanPage> listChatBans({
    required String eventID,
    int? page,
    int? pageSize,
  }) async {
    try {
      final banPage = await _apiClient.listChatBans(
        eventID: eventID,
        page: page,
        pageSize: pageSize,
      );
      return banPage.toDomain();
    } on api.M3tApiException catch (e) {
      throwChatFailure(e);
    }
  }
}

final class _ChatRealtimeHandleImpl implements domain.ChatRealtimeHandle {
  _ChatRealtimeHandleImpl({required void Function() onCancel})
    : _onCancel = onCancel;

  final void Function() _onCancel;

  @override
  void cancel() => _onCancel();
}

domain.ChatRealtimeEvent? _parseChatRealtimeEvent(api.WsFrame frame) {
  final data = frame.data;
  if (data == null) return null;

  return switch (frame.type) {
    'chat.message' => () {
      final message = chatMessageFromWsData(data);
      return message != null
          ? domain.ChatMessageReceived(message: message)
          : null;
    }(),
    'chat.message.deleted' => () {
      final messageId = data['message_id'] as String?;
      final eventId = data['event_id'] as String?;
      final channelTypeRaw = data['channel_type'] as String?;
      if (messageId == null || eventId == null || channelTypeRaw == null) {
        return null;
      }
      final deletedAtRaw = data['deleted_at'] as String?;
      return domain.ChatMessageDeleted(
        messageId: messageId,
        eventId: eventId,
        channelType: domain.chatChannelTypeFromApiValue(channelTypeRaw),
        conversationId: data['conversation_id'] as String?,
        deletedAt: deletedAtRaw != null
            ? DateTime.tryParse(deletedAtRaw)
            : null,
      );
    }(),
    'chat.reaction.added' => () {
      final messageId = data['message_id'] as String?;
      if (messageId == null) return null;
      return domain.ChatReactionAdded(
        messageId: messageId,
        reactions: chatReactionsFromWsData(data),
      );
    }(),
    'chat.reaction.removed' => () {
      final messageId = data['message_id'] as String?;
      if (messageId == null) return null;
      return domain.ChatReactionRemoved(
        messageId: messageId,
        reactions: chatReactionsFromWsData(data),
      );
    }(),
    _ => null,
  };
}

/// Maps transport-layer [api.M3tApiException] to [domain.ChatFailure].
Never throwChatFailure(api.M3tApiException e) {
  switch (e.errorCode) {
    case 'not_registered_for_event':
      throw domain.ChatNotRegisteredForEvent();
    case 'chat_banned':
    case 'chat_banned_from_event':
      throw domain.ChatBanned();
    case 'invalid_or_expired_token':
      throw domain.ChatInvalidOrExpiredToken();
    case 'unprocessable_entity':
      throw domain.ChatUnprocessableEntity();
    case 'not_found':
    case 'message_not_found':
      throw domain.ChatNotFound();
    case 'conflict':
      throw domain.ChatConflict();
    case 'unauthorized':
      throw domain.ChatUnauthorized();
    case 'forbidden':
    case 'not_event_owner':
    case 'not_event_team_member':
      throw domain.ChatForbidden();
    case 'missing_path_param':
    case 'invalid_path_param':
    case 'invalid_query_param':
    case 'invalid_request_body':
      throw domain.ChatInvalidInput();
    case 'internal_error':
      throw domain.ChatUnknownError();
  }
  switch (e.statusCode) {
    case 400:
      throw domain.ChatInvalidInput();
    case 401:
      throw domain.ChatUnauthorized();
    case 403:
      throw domain.ChatForbidden();
    case 404:
      throw domain.ChatNotFound();
    case 409:
      throw domain.ChatConflict();
    case 422:
      throw domain.ChatUnprocessableEntity();
    case 500:
      throw domain.ChatUnknownError();
  }
  throw domain.ChatNetworkError();
}
