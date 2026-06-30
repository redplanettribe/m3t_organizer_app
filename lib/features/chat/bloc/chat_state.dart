part of 'chat_cubit.dart';

final class ChatState extends Equatable {
  const ChatState({
    this.selectedTab = ChatChannelTab.general,
    this.dmInboxConnected = false,
  });

  final ChatChannelTab selectedTab;
  final bool dmInboxConnected;

  ChatState copyWith({
    ChatChannelTab? selectedTab,
    bool? dmInboxConnected,
  }) {
    return ChatState(
      selectedTab: selectedTab ?? this.selectedTab,
      dmInboxConnected: dmInboxConnected ?? this.dmInboxConnected,
    );
  }

  @override
  List<Object?> get props => [selectedTab, dmInboxConnected];
}
