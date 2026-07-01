part of 'chat_unread_cubit.dart';

final class ChatUnreadState extends Equatable {
  const ChatUnreadState({
    this.generalUnread = 0,
    this.organizersUnread = 0,
    this.dmUnreadByConversation = const {},
  });

  final int generalUnread;
  final int organizersUnread;
  final Map<String, int> dmUnreadByConversation;

  int get dmsUnread =>
      dmUnreadByConversation.values.fold<int>(0, (sum, count) => sum + count);

  int get totalUnread => generalUnread + organizersUnread + dmsUnread;

  int dmUnreadFor(String conversationId) =>
      dmUnreadByConversation[conversationId.toLowerCase()] ?? 0;

  ChatUnreadState copyWith({
    int? generalUnread,
    int? organizersUnread,
    Map<String, int>? dmUnreadByConversation,
  }) {
    return ChatUnreadState(
      generalUnread: generalUnread ?? this.generalUnread,
      organizersUnread: organizersUnread ?? this.organizersUnread,
      dmUnreadByConversation:
          dmUnreadByConversation ?? this.dmUnreadByConversation,
    );
  }

  @override
  List<Object?> get props => [
    generalUnread,
    organizersUnread,
    dmUnreadByConversation,
  ];
}
