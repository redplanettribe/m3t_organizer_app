import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/push/chat_push_dedupe.dart';
import 'package:m3t_organizer/core/push/foreground_chat_tab.dart';
import 'package:m3t_organizer/core/push/push_navigation_intent.dart';
import 'package:m3t_organizer/core/push/push_notification_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/dm_inbox_cubit.dart';
import 'package:m3t_organizer/features/chat/general/view/general_chat_view.dart';
import 'package:m3t_organizer/features/chat/view/chat_bans_view.dart';
import 'package:m3t_organizer/features/chat/view/dm_inbox_view.dart';
import 'package:m3t_organizer/features/chat/view/open_dm_thread.dart';
import 'package:m3t_organizer/features/chat/view/organizers_chat_view.dart';
import 'package:m3t_organizer/features/user/user.dart';

final class ChatHomePage extends StatelessWidget {
  const ChatHomePage({
    required this.eventID,
    this.pushIntent,
    super.key,
  });

  final String eventID;
  final PushNavigationIntent? pushIntent;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<UserCubit, String?>(
      (c) => c.state.user?.id,
    );

    return BlocProvider(
      create: (context) => ChatCubit(
        chatRepository: context.read<ChatRepository>(),
        eventID: eventID,
      ),
      child: _ChatHomeView(
        eventID: eventID,
        currentUserId: currentUserId,
        pushIntent: pushIntent,
      ),
    );
  }
}

final class _ChatHomeView extends StatefulWidget {
  const _ChatHomeView({
    required this.eventID,
    required this.currentUserId,
    required this.pushIntent,
  });

  final String eventID;
  final String? currentUserId;
  final PushNavigationIntent? pushIntent;

  @override
  State<_ChatHomeView> createState() => _ChatHomeViewState();
}

final class _ChatHomeViewState extends State<_ChatHomeView> {
  var _handledPushIntent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncActiveChatTab(context.read<ChatCubit>().state.selectedTab);
    });
  }

  ForegroundChatTab? _foregroundTabFor(ChatChannelTab tab) {
    return switch (tab) {
      ChatChannelTab.general => ForegroundChatTab.general,
      ChatChannelTab.dms => ForegroundChatTab.dms,
      ChatChannelTab.organizers => ForegroundChatTab.organizers,
      ChatChannelTab.banned => null,
    };
  }

  void _syncActiveChatTab(ChatChannelTab tab) {
    context.read<PushNotificationCubit>().setActiveChatTab(
      eventId: widget.eventID,
      tab: _foregroundTabFor(tab),
    );
  }

  @override
  void didUpdateWidget(covariant _ChatHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pushIntent != widget.pushIntent) {
      _handledPushIntent = false;
    }
    _maybeHandlePushIntent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeHandlePushIntent();
  }

  void _maybeHandlePushIntent() {
    if (_handledPushIntent || widget.pushIntent == null) {
      return;
    }

    final currentUserId = widget.currentUserId;
    if (currentUserId == null) {
      return;
    }

    _handledPushIntent = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _applyPushIntent(widget.pushIntent!, currentUserId);
    });
  }

  void _applyPushIntent(PushNavigationIntent intent, String currentUserId) {
    final chatCubit = context.read<ChatCubit>();
    switch (intent) {
      case OpenEventChatGeneralIntent():
        chatCubit.selectChannel(ChatChannelTab.general);
      case OpenEventChatOrganizersIntent():
        chatCubit.selectChannel(ChatChannelTab.organizers);
      case OpenEventDmIntent(
        :final recipientUserId,
        :final recipientDisplayName,
      ):
        chatCubit.selectChannel(ChatChannelTab.dms);
        openDmThread(
          context,
          eventID: widget.eventID,
          recipientUserId: recipientUserId,
          currentUserId: currentUserId,
          recipientDisplayName: recipientDisplayName,
        );
      case OpenEventIntent():
      case OpenEventSessionsIntent():
      case OpenUrlIntent():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      listener: (context, state) => _syncActiveChatTab(state.selectedTab),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SegmentedButton<ChatChannelTab>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: ChatChannelTab.general,
                      label: Text('General'),
                    ),
                    ButtonSegment(
                      value: ChatChannelTab.dms,
                      label: Text('DMs'),
                    ),
                    ButtonSegment(
                      value: ChatChannelTab.organizers,
                      label: Text('Team'),
                    ),
                    ButtonSegment(
                      value: ChatChannelTab.banned,
                      label: Text('Banned'),
                    ),
                  ],
                  selected: {state.selectedTab},
                  onSelectionChanged: (selection) {
                    context.read<ChatCubit>().selectChannel(selection.first);
                  },
                ),
              ),
              Expanded(
                child: switch (state.selectedTab) {
                  ChatChannelTab.general => GeneralChatTab(
                    eventID: widget.eventID,
                  ),
                  ChatChannelTab.dms => _DmTabBody(
                    eventID: widget.eventID,
                    currentUserId: widget.currentUserId,
                  ),
                  ChatChannelTab.organizers => OrganizersChatView(
                    eventID: widget.eventID,
                    currentUserId: widget.currentUserId,
                  ),
                  ChatChannelTab.banned => ChatBansView(
                    eventID: widget.eventID,
                  ),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

final class _DmTabBody extends StatelessWidget {
  const _DmTabBody({
    required this.eventID,
    required this.currentUserId,
  });

  final String eventID;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your profile…'),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (context) => DmInboxCubit(
        chatRepository: context.read<ChatRepository>(),
        eventsRepository: context.read<EventsRepository>(),
        eventID: eventID,
        currentUserId: currentUserId,
        realtimeEvents: context.read<ChatCubit>().realtimeEvents,
        onMessageDeliveredViaRealtime: rememberChatMessageForPush(context),
      ),
      child: DmInboxView(
        eventID: eventID,
        currentUserId: currentUserId!,
      ),
    );
  }
}
