import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/media/media_url_resolver.dart';
import 'package:m3t_organizer/features/attendee/bloc/attendee_registration_cubit.dart';
import 'package:m3t_organizer/features/chat/view/open_dm_thread.dart';
import 'package:m3t_organizer/features/user/user.dart';

/// Organizer view of a registered attendee for an event.
final class AttendeeRegistrationPage extends StatefulWidget {
  const AttendeeRegistrationPage({
    required this.eventID,
    required this.userID,
    this.fallbackName,
    this.fallbackLastName,
    this.fallbackProfilePictureUrl,
    super.key,
  });

  final String eventID;
  final String userID;
  final String? fallbackName;
  final String? fallbackLastName;
  final String? fallbackProfilePictureUrl;

  @override
  State<AttendeeRegistrationPage> createState() =>
      _AttendeeRegistrationPageState();
}

final class _AttendeeRegistrationPageState
    extends State<AttendeeRegistrationPage> {
  @override
  void initState() {
    super.initState();
    unawaited(
      context.read<AttendeeRegistrationCubit>().load(
        eventID: widget.eventID,
        userID: widget.userID,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendeeRegistrationCubit, AttendeeRegistrationState>(
      builder: (context, state) {
        final registration = state.registration;
        final displayName = _displayName(registration);
        final resolvedAvatarUrl = _resolvedAvatarUrl(registration);
        final currentUserId = context.select<UserCubit, String?>(
          (c) => c.state.user?.id,
        );
        final canSendMessage =
            currentUserId != null && widget.userID != currentUserId;
        final onSendMessage = canSendMessage
            ? () => openDmThread(
                context,
                eventID: widget.eventID,
                recipientUserId: widget.userID,
                currentUserId: currentUserId,
                recipientDisplayName: displayName,
                replaceCurrentRoute: true,
              )
            : null;

        return Scaffold(
          appBar: AppBar(title: Text(displayName)),
          body: switch (state.status) {
            AttendeeRegistrationStatus.initial ||
            AttendeeRegistrationStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            AttendeeRegistrationStatus.failure => _FailureBody(
              message: state.errorMessage ?? 'Could not load attendee.',
              onRetry: () => context.read<AttendeeRegistrationCubit>().load(
                eventID: widget.eventID,
                userID: widget.userID,
              ),
            ),
            AttendeeRegistrationStatus.notFound => _ProfileBody(
              displayName: displayName,
              resolvedAvatarUrl: resolvedAvatarUrl,
              initials: _initials(
                name: widget.fallbackName,
                lastName: widget.fallbackLastName,
                fallback: widget.userID,
              ),
              notRegisteredMessage: 'Not registered for this event.',
              onSendMessage: onSendMessage,
            ),
            AttendeeRegistrationStatus.ready => _ProfileBody(
              displayName: displayName,
              resolvedAvatarUrl: resolvedAvatarUrl,
              initials: _initials(
                name: registration?.name ?? widget.fallbackName,
                lastName: registration?.lastName ?? widget.fallbackLastName,
                fallback: widget.userID,
              ),
              email: registration?.email,
              tierName: registration?.tierName,
              checkedIn: registration?.checkedIn,
              onSendMessage: onSendMessage,
            ),
          },
        );
      },
    );
  }

  String _displayName(EventRegistration? registration) {
    if (registration != null) {
      return registration.displayName;
    }

    final fallback = [
      widget.fallbackName,
      widget.fallbackLastName,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    return fallback.isNotEmpty ? fallback : widget.userID;
  }

  String? _resolvedAvatarUrl(EventRegistration? registration) {
    final fromChat = MediaUrlResolver.resolveAppUrl(
      widget.fallbackProfilePictureUrl,
    );
    if (fromChat != null && fromChat.isNotEmpty) {
      return fromChat;
    }
    return null;
  }
}

final class _FailureBody extends StatelessWidget {
  const _FailureBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

final class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.displayName,
    required this.initials,
    this.resolvedAvatarUrl,
    this.email,
    this.tierName,
    this.checkedIn,
    this.notRegisteredMessage,
    this.onSendMessage,
  });

  final String displayName;
  final String initials;
  final String? resolvedAvatarUrl;
  final String? email;
  final String? tierName;
  final bool? checkedIn;
  final String? notRegisteredMessage;
  final VoidCallback? onSendMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _AttendeeAvatar(
              imageUrl: resolvedAvatarUrl,
              initials: initials,
              radius: 52,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              displayName,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (notRegisteredMessage != null) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                notRegisteredMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          if (email != null && email!.trim().isNotEmpty) ...[
            const SizedBox(height: 24),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email!,
            ),
          ],
          if (tierName != null && tierName!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.confirmation_number_outlined,
              label: 'Tier',
              value: tierName!,
            ),
          ],
          if (checkedIn != null) ...[
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.how_to_reg_outlined,
              label: 'Checked in',
              value: checkedIn! ? 'Yes' : 'No',
            ),
          ],
          if (onSendMessage != null) ...[
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: onSendMessage,
              icon: const Icon(Icons.mail_outline),
              label: const Text('Send private message'),
            ),
          ],
        ],
      ),
    );
  }
}

final class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

final class _AttendeeAvatar extends StatelessWidget {
  const _AttendeeAvatar({
    required this.initials,
    required this.radius,
    this.imageUrl,
  });

  final String? imageUrl;
  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diameter = radius * 2;
    final style = theme.textTheme.headlineLarge?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Center(child: Text(initials, style: style)),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(initials, style: style),
    );
  }
}

String _initials({
  required String? name,
  required String? lastName,
  required String fallback,
}) {
  final trimmedName = name?.trim();
  final trimmedLastName = lastName?.trim();
  if (trimmedName != null &&
      trimmedName.isNotEmpty &&
      trimmedLastName != null &&
      trimmedLastName.isNotEmpty) {
    return '${trimmedName[0]}${trimmedLastName[0]}'.toUpperCase();
  }
  if (trimmedName != null && trimmedName.isNotEmpty) {
    return trimmedName.length >= 2
        ? trimmedName.substring(0, 2).toUpperCase()
        : trimmedName[0].toUpperCase();
  }
  if (fallback.length >= 2) {
    return fallback.substring(0, 2).toUpperCase();
  }
  return fallback.isNotEmpty ? fallback[0].toUpperCase() : '?';
}
