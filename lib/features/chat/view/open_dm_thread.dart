import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';
import 'package:m3t_organizer/features/chat/view/dm_thread_page.dart';

/// Opens a 1:1 DM thread with [recipientUserId] for [eventID].
void openDmThread(
  BuildContext context, {
  required String eventID,
  required String recipientUserId,
  required String currentUserId,
  String? recipientDisplayName,
  bool replaceCurrentRoute = false,
}) {
  final chatCubit = context.read<ChatCubit>();
  final route = MaterialPageRoute<void>(
    builder: (context) => BlocProvider.value(
      value: chatCubit,
      child: DmThreadPage(
        eventID: eventID,
        recipientUserId: recipientUserId,
        currentUserId: currentUserId,
        recipientDisplayName: recipientDisplayName,
      ),
    ),
  );

  final navigator = Navigator.of(context);
  unawaited(
    replaceCurrentRoute
        ? navigator.pushReplacement(route)
        : navigator.push<void>(route),
  );
}
