import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/attendee/attendee.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_cubit.dart';

/// Opens the attendee registration profile for a chat message sender.
void openAttendeeRegistration(
  BuildContext context, {
  required String eventID,
  required ChatMessage message,
}) {
  final chatCubit = context.read<ChatCubit>();

  unawaited(
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<ChatCubit>.value(value: chatCubit),
            BlocProvider(
              create: (context) => AttendeeRegistrationCubit(
                eventsRepository: context.read<EventsRepository>(),
              ),
            ),
          ],
          child: AttendeeRegistrationPage(
            eventID: eventID,
            userID: message.senderUserId,
            fallbackName: message.senderName,
            fallbackLastName: message.senderLastName,
            fallbackProfilePictureUrl: message.senderProfilePictureUrl,
          ),
        ),
      ),
    ),
  );
}
