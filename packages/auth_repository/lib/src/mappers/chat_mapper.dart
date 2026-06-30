import 'package:domain/domain.dart' as domain;
import 'package:m3t_api/m3t_api.dart' as api;

extension ApiChatReplyToMapper on api.ChatReplyTo {
  domain.ChatReplyTo toDomain() => domain.ChatReplyTo(
    messageId: messageId,
    senderUserId: senderUserId,
    senderName: senderName,
    senderLastName: senderLastName,
    body: body,
    deleted: deleted,
  );
}

extension ApiChatReactionMapper on api.ChatReaction {
  domain.ChatReaction toDomain() => domain.ChatReaction(
    emoji: emoji,
    count: count,
    reactedByMe: reactedByMe,
  );
}

extension ApiChatMessageMapper on api.ChatMessage {
  domain.ChatMessage toDomain() => domain.ChatMessage(
    messageId: messageId,
    eventId: eventId,
    channelType: domain.chatChannelTypeFromApiValue(channelType),
    conversationId: conversationId,
    senderUserId: senderUserId,
    senderName: senderName,
    senderLastName: senderLastName,
    senderProfilePictureUrl: senderProfilePictureUrl,
    recipientUserId: recipientUserId,
    body: body,
    replyTo: replyTo?.toDomain(),
    reactions: reactions?.map((r) => r.toDomain()).toList(),
    createdAt: DateTime.parse(createdAt),
  );
}

extension ApiChatMessagePageMapper on api.ChatMessagePage {
  domain.ChatMessagePage toDomain() => domain.ChatMessagePage(
    items: items.map((m) => m.toDomain()).toList(),
    nextCursor: nextCursor,
  );
}

extension ApiChatMessageReactionsMapper on api.ChatMessageReactions {
  List<domain.ChatReaction> reactionsToDomain() =>
      reactions.map((r) => r.toDomain()).toList();
}

extension ApiChatBanMapper on api.ChatBan {
  domain.ChatBan toDomain() => domain.ChatBan(
    userId: userId,
    userName: userName,
    userLastName: userLastName,
    bannedByUserId: bannedByUserId,
    bannedByName: bannedByName,
    bannedByLastName: bannedByLastName,
    bannedAt: bannedAt != null ? DateTime.tryParse(bannedAt!) : null,
  );
}

extension ApiChatBanPageMapper on api.ChatBanPage {
  domain.ChatBanPage toDomain() => domain.ChatBanPage(
    items: items.map((b) => b.toDomain()).toList(),
    page: pagination?.page,
    pageSize: pagination?.pageSize,
    total: pagination?.total,
    totalPages: pagination?.totalPages,
  );
}

extension ApiChatConversationMapper on api.ChatConversation {
  domain.ChatConversation toDomain() => domain.ChatConversation(
    conversationId: conversationId,
    otherUserId: otherUserId,
    lastMessage: lastMessage?.toDomain(),
  );
}

extension ApiChatConversationPageMapper on api.ChatConversationPage {
  domain.ChatConversationPage toDomain() => domain.ChatConversationPage(
    items: items.map((c) => c.toDomain()).toList(),
    nextCursor: nextCursor,
  );
}

domain.ChatMessage? chatMessageFromWsData(Map<String, dynamic> data) {
  try {
    return api.ChatMessage.fromJson(data).toDomain();
  } on Object {
    return null;
  }
}

List<domain.ChatReaction> chatReactionsFromWsData(Map<String, dynamic> data) {
  final reactions = data['reactions'];
  if (reactions is! List) return const [];
  return reactions
      .whereType<Map<String, dynamic>>()
      .map(api.ChatReaction.fromJson)
      .map((r) => r.toDomain())
      .toList();
}
