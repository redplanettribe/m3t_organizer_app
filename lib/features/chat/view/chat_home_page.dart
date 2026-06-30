import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';
import 'package:m3t_organizer/features/chat/bloc/dm_inbox_cubit.dart';
import 'package:m3t_organizer/features/chat/general/view/general_chat_view.dart';
import 'package:m3t_organizer/features/chat/view/chat_bans_view.dart';
import 'package:m3t_organizer/features/chat/view/dm_inbox_view.dart';
import 'package:m3t_organizer/features/chat/view/organizers_chat_view.dart';
import 'package:m3t_organizer/features/user/user.dart';

final class ChatHomePage extends StatelessWidget {
  const ChatHomePage({required this.eventID, super.key});

  final String eventID;

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
      ),
    );
  }
}

final class _ChatHomeView extends StatelessWidget {
  const _ChatHomeView({
    required this.eventID,
    required this.currentUserId,
  });

  final String eventID;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
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
                ChatChannelTab.general => GeneralChatTab(eventID: eventID),
                ChatChannelTab.dms => _DmTabBody(
                  eventID: eventID,
                  currentUserId: currentUserId,
                ),
                ChatChannelTab.organizers => OrganizersChatView(
                  eventID: eventID,
                  currentUserId: currentUserId,
                ),
                ChatChannelTab.banned => ChatBansView(eventID: eventID),
              },
            ),
          ],
        );
      },
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
      ),
      child: DmInboxView(
        eventID: eventID,
        currentUserId: currentUserId!,
      ),
    );
  }
}
