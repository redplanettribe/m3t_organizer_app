import 'dart:convert';

import 'package:m3t_api/src/exceptions.dart';
import 'package:m3t_api/src/http/api_http_executor.dart';
import 'package:m3t_api/src/http/api_paths.dart';
import 'package:m3t_api/src/models/chat_ban.dart';
import 'package:m3t_api/src/models/chat_ban_page.dart';
import 'package:m3t_api/src/models/chat_conversation.dart';
import 'package:m3t_api/src/models/chat_conversation_page.dart';
import 'package:m3t_api/src/models/chat_message.dart';
import 'package:m3t_api/src/models/chat_message_page.dart';
import 'package:m3t_api/src/models/chat_message_reactions.dart';
import 'package:m3t_api/src/models/chat_reaction_request.dart';
import 'package:m3t_api/src/models/pagination_meta.dart';
import 'package:m3t_api/src/models/send_chat_message_request.dart';

/// REST endpoints for event-scoped chat.
final class ChatDataSource {
  const ChatDataSource({required ApiHttpExecutor executor})
    : _executor = executor;

  final ApiHttpExecutor _executor;

  ApiHttpExecutor get executor => _executor;

  Future<ChatMessagePage> getGeneralMessages({
    required String eventID,
    String? cursor,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (cursor != null) {
      query['cursor'] = cursor;
    }
    if (limit != null) {
      query['limit'] = '$limit';
    }

    final response = await _executor.client.get(
      _executor.uri(ChatPaths.generalMessages(eventID)).replace(
        queryParameters: query.isEmpty ? null : query,
      ),
      headers: await _executor.authHeaders(),
    );

    final page = _executor.parseCursorEnvelope(
      response,
      onError: _getGeneralMessagesOnError,
    );

    return ChatMessagePage(
      items: page.items.map(ChatMessage.fromJson).toList(),
      nextCursor: page.nextCursor,
    );
  }

  Future<ChatMessage> sendGeneralMessage({
    required String eventID,
    required String body,
    String? clientMsgId,
    String? replyToMessageId,
  }) async {
    final request = SendChatMessageRequest(
      body: body,
      clientMsgId: clientMsgId,
      replyToMessageId: replyToMessageId,
    );

    final response = await _executor.client.post(
      _executor.uri(ChatPaths.generalMessages(eventID)),
      headers: await _executor.authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _sendGeneralMessageOnError,
    );

    if (data == null) {
      throw SendGeneralChatMessageFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatMessage.fromJson(data);
  }

  Future<void> deleteAttendeeMessage({
    required String eventID,
    required String messageID,
  }) async {
    final response = await _executor.client.delete(
      _executor.uri(
        ChatPaths.attendeeMessage(eventID: eventID, messageID: messageID),
      ),
      headers: await _executor.authHeaders(),
    );

    _executor.parseVoidEnvelope(
      response,
      onError: _deleteAttendeeMessageOnError,
    );
  }

  Future<ChatMessageReactions> setMessageReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  }) async {
    final response = await _executor.client.put(
      _executor.uri(
        ChatPaths.attendeeMessageReactions(
          eventID: eventID,
          messageID: messageID,
        ),
      ),
      headers: await _executor.authHeaders(),
      body: jsonEncode(ChatReactionRequest(emoji: emoji).toJson()),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _setMessageReactionOnError,
    );

    if (data == null) {
      throw SetChatMessageReactionFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatMessageReactions.fromJson(data);
  }

  Future<ChatMessageReactions> removeMessageReaction({
    required String eventID,
    required String messageID,
  }) async {
    final response = await _executor.client.delete(
      _executor.uri(
        ChatPaths.attendeeMessageReactions(
          eventID: eventID,
          messageID: messageID,
        ),
      ),
      headers: await _executor.authHeaders(),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _removeMessageReactionOnError,
    );

    if (data == null) {
      throw RemoveChatMessageReactionFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatMessageReactions.fromJson(data);
  }

  Future<ChatConversationPage> getDmConversations({
    required String eventID,
    String? cursor,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (cursor != null) {
      query['cursor'] = cursor;
    }
    if (limit != null) {
      query['limit'] = '$limit';
    }

    final response = await _executor.client.get(
      _executor.uri(ChatPaths.dmConversations(eventID)).replace(
        queryParameters: query.isEmpty ? null : query,
      ),
      headers: await _executor.authHeaders(),
    );

    final page = _executor.parseCursorEnvelope(
      response,
      onError: _getDmConversationsOnError,
    );

    return ChatConversationPage(
      items: page.items.map(ChatConversation.fromJson).toList(),
      nextCursor: page.nextCursor,
    );
  }

  Future<ChatMessagePage> getDmMessages({
    required String eventID,
    required String recipientUserID,
    String? cursor,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (cursor != null) {
      query['cursor'] = cursor;
    }
    if (limit != null) {
      query['limit'] = '$limit';
    }

    final response = await _executor.client.get(
      _executor.uri(
        ChatPaths.dmMessages(
          eventID: eventID,
          recipientUserID: recipientUserID,
        ),
      ).replace(queryParameters: query.isEmpty ? null : query),
      headers: await _executor.authHeaders(),
    );

    final page = _executor.parseCursorEnvelope(
      response,
      onError: _getDmMessagesOnError,
    );

    return ChatMessagePage(
      items: page.items.map(ChatMessage.fromJson).toList(),
      nextCursor: page.nextCursor,
    );
  }

  Future<ChatMessage> sendDmMessage({
    required String eventID,
    required String recipientUserID,
    required SendChatMessageRequest request,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(
        ChatPaths.dmMessages(
          eventID: eventID,
          recipientUserID: recipientUserID,
        ),
      ),
      headers: await _executor.authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _sendDmMessageOnError,
    );

    if (data == null) {
      throw SendDmMessageFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatMessage.fromJson(data);
  }

  Future<ChatMessagePage> getOrganizerMessages({
    required String eventID,
    String? cursor,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (cursor != null) {
      query['cursor'] = cursor;
    }
    if (limit != null) {
      query['limit'] = '$limit';
    }

    final response = await _executor.client.get(
      _executor.uri(ChatPaths.organizerMessages(eventID)).replace(
        queryParameters: query.isEmpty ? null : query,
      ),
      headers: await _executor.authHeaders(),
    );

    final page = _executor.parseCursorEnvelope(
      response,
      onError: _getOrganizerMessagesOnError,
    );

    return ChatMessagePage(
      items: page.items.map(ChatMessage.fromJson).toList(),
      nextCursor: page.nextCursor,
    );
  }

  Future<ChatMessage> sendOrganizerMessage({
    required String eventID,
    required SendChatMessageRequest request,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(ChatPaths.organizerMessages(eventID)),
      headers: await _executor.authHeaders(),
      body: jsonEncode(request.toJson()),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _sendOrganizerMessageOnError,
    );

    if (data == null) {
      throw SendOrganizerChatMessageFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatMessage.fromJson(data);
  }

  Future<void> deleteOrganizerMessage({
    required String eventID,
    required String messageID,
  }) async {
    final response = await _executor.client.delete(
      _executor.uri(
        ChatPaths.organizerMessage(eventID: eventID, messageID: messageID),
      ),
      headers: await _executor.authHeaders(),
    );

    _executor.parseVoidEnvelope(
      response,
      onError: _deleteOrganizerMessageOnError,
    );
  }

  Future<ChatMessageReactions> setOrganizerMessageReaction({
    required String eventID,
    required String messageID,
    required String emoji,
  }) async {
    final response = await _executor.client.put(
      _executor.uri(
        ChatPaths.organizerMessageReactions(
          eventID: eventID,
          messageID: messageID,
        ),
      ),
      headers: await _executor.authHeaders(),
      body: jsonEncode(ChatReactionRequest(emoji: emoji).toJson()),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _setOrganizerReactionOnError,
    );

    if (data == null) {
      throw SetOrganizerChatReactionFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatMessageReactions.fromJson(data);
  }

  Future<ChatMessageReactions> removeOrganizerMessageReaction({
    required String eventID,
    required String messageID,
  }) async {
    final response = await _executor.client.delete(
      _executor.uri(
        ChatPaths.organizerMessageReactions(
          eventID: eventID,
          messageID: messageID,
        ),
      ),
      headers: await _executor.authHeaders(),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _removeOrganizerReactionOnError,
    );

    if (data == null) {
      throw RemoveOrganizerChatReactionFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatMessageReactions.fromJson(data);
  }

  Future<void> deleteGeneralMessageAsOrganizer({
    required String eventID,
    required String messageID,
  }) async {
    final response = await _executor.client.delete(
      _executor.uri(
        ChatPaths.organizerDeleteGeneralMessage(
          eventID: eventID,
          messageID: messageID,
        ),
      ),
      headers: await _executor.authHeaders(),
    );

    _executor.parseVoidEnvelope(
      response,
      onError: _deleteGeneralMessageOnError,
    );
  }

  Future<ChatBan> banChatUser({
    required String eventID,
    required String userID,
  }) async {
    final response = await _executor.client.post(
      _executor.uri(ChatPaths.chatBan(eventID: eventID, userID: userID)),
      headers: await _executor.authHeaders(),
    );

    final data = _executor.parseEnvelope(
      response,
      onError: _banChatUserOnError,
    );

    if (data == null) {
      throw BanChatUserFailure(
        'Missing data field in response',
        statusCode: response.statusCode,
      );
    }

    return ChatBan.fromJson(data);
  }

  Future<void> unbanChatUser({
    required String eventID,
    required String userID,
  }) async {
    final response = await _executor.client.delete(
      _executor.uri(ChatPaths.chatBan(eventID: eventID, userID: userID)),
      headers: await _executor.authHeaders(),
    );

    _executor.parseVoidEnvelope(
      response,
      onError: _unbanChatUserOnError,
    );
  }

  Future<ChatBanPage> listChatBans({
    required String eventID,
    int? page,
    int? pageSize,
  }) async {
    final query = <String, String>{};
    if (page != null) {
      query['page'] = '$page';
    }
    if (pageSize != null) {
      query['page_size'] = '$pageSize';
    }

    final response = await _executor.client.get(
      _executor.uri(ChatPaths.chatBans(eventID)).replace(
        queryParameters: query.isEmpty ? null : query,
      ),
      headers: await _executor.authHeaders(),
    );

    final pageData = _executor.parsePaginatedEnvelope(
      response,
      onError: _listChatBansOnError,
    );

    return ChatBanPage(
      items: pageData.items.map(ChatBan.fromJson).toList(),
      pagination: pageData.pagination != null
          ? PaginationMeta.fromJson(pageData.pagination!)
          : null,
    );
  }

  static GetOrganizerChatMessagesFailure _getOrganizerMessagesOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => GetOrganizerChatMessagesFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static SendOrganizerChatMessageFailure _sendOrganizerMessageOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => SendOrganizerChatMessageFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static DeleteOrganizerChatMessageFailure _deleteOrganizerMessageOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => DeleteOrganizerChatMessageFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static SetOrganizerChatReactionFailure _setOrganizerReactionOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => SetOrganizerChatReactionFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static RemoveOrganizerChatReactionFailure _removeOrganizerReactionOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => RemoveOrganizerChatReactionFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static DeleteGeneralChatMessageFailure _deleteGeneralMessageOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => DeleteGeneralChatMessageFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static BanChatUserFailure _banChatUserOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => BanChatUserFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static UnbanChatUserFailure _unbanChatUserOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => UnbanChatUserFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static ListChatBansFailure _listChatBansOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => ListChatBansFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static GetGeneralChatMessagesFailure _getGeneralMessagesOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => GetGeneralChatMessagesFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static SendGeneralChatMessageFailure _sendGeneralMessageOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => SendGeneralChatMessageFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static DeleteAttendeeChatMessageFailure _deleteAttendeeMessageOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => DeleteAttendeeChatMessageFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static SetChatMessageReactionFailure _setMessageReactionOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => SetChatMessageReactionFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static RemoveChatMessageReactionFailure _removeMessageReactionOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => RemoveChatMessageReactionFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static GetDmConversationsFailure _getDmConversationsOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => GetDmConversationsFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static GetDmMessagesFailure _getDmMessagesOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => GetDmMessagesFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );

  static SendDmMessageFailure _sendDmMessageOnError({
    required String message,
    required int statusCode,
    String? errorCode,
    bool showToUser = false,
  }) => SendDmMessageFailure(
    message,
    statusCode: statusCode,
    errorCode: errorCode,
    showToUser: showToUser,
  );
}
