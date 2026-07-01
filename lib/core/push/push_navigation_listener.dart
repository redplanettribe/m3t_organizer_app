import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_organizer/app/routes.dart';
import 'package:m3t_organizer/core/push/push_navigation_intent.dart';
import 'package:m3t_organizer/core/push/push_notification_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

/// Routes [PushNotificationCubit] pending intents through [GoRouter].
final class PushNavigationListener extends StatefulWidget {
  const PushNavigationListener({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  @override
  State<PushNavigationListener> createState() => _PushNavigationListenerState();
}

final class _PushNavigationListenerState extends State<PushNavigationListener> {
  var _handledInitialIntent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialIntent) {
      return;
    }
    _handledInitialIntent = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final intent = context
          .read<PushNotificationCubit>()
          .state
          .pendingNavigation;
      if (intent != null) {
        unawaited(_navigate(intent));
        context.read<PushNotificationCubit>().clearPendingNavigation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PushNotificationCubit, PushNotificationState>(
      listenWhen: (previous, current) =>
          current.pendingNavigation != null &&
          current.pendingNavigation != previous.pendingNavigation,
      listener: (context, state) {
        final intent = state.pendingNavigation;
        if (intent == null) {
          return;
        }

        unawaited(_navigate(intent));
        context.read<PushNotificationCubit>().clearPendingNavigation();
      },
      child: widget.child,
    );
  }

  Future<void> _navigate(PushNavigationIntent intent) async {
    switch (intent) {
      case OpenUrlIntent(:final url):
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      case OpenEventIntent(:final eventId):
        widget.router.go(
          AppRoutes.eventById(eventId),
          extra: EventRouteExtra(pushIntent: intent),
        );
      case OpenEventChatGeneralIntent(:final eventId):
        widget.router.go(
          AppRoutes.eventById(eventId),
          extra: EventRouteExtra(pushIntent: intent),
        );
      case OpenEventChatOrganizersIntent(:final eventId):
        widget.router.go(
          AppRoutes.eventById(eventId),
          extra: EventRouteExtra(pushIntent: intent),
        );
      case OpenEventDmIntent(:final eventId):
        widget.router.go(
          AppRoutes.eventById(eventId),
          extra: EventRouteExtra(pushIntent: intent),
        );
      case OpenEventSessionsIntent(:final eventId):
        widget.router.go(
          AppRoutes.eventById(eventId),
          extra: EventRouteExtra(pushIntent: intent),
        );
    }
  }
}
