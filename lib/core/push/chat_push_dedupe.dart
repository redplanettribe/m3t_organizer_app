import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/push/push_notification_cubit.dart';

/// Callback for chat cubits to register WS-delivered messages with push.
void Function(String messageId) rememberChatMessageForPush(
  BuildContext context,
) {
  return (messageId) =>
      context.read<PushNotificationCubit>().rememberDeliveredMessage(messageId);
}
