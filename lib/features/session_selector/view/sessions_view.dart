import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/core/events/events_failure_message.dart';
import 'package:m3t_organizer/features/session_check_in/session_check_in.dart';
import 'package:m3t_organizer/features/session_selector/bloc/session_selector_cubit.dart';
import 'package:m3t_organizer/features/session_selector/view/session_selector_sheet.dart';
import 'package:m3t_organizer/features/session_status/session_status.dart';
import 'package:m3t_organizer/layout/sections/sessions_layout.dart';

final class SessionsView extends StatefulWidget {
  const SessionsView({
    required this.eventID,
    this.onSheetExpanded,
    super.key,
  });

  final String eventID;
  final ValueChanged<bool>? onSheetExpanded;

  @override
  State<SessionsView> createState() => _SessionsViewState();
}

final class _SessionsViewState extends State<SessionsView>
    with AutomaticKeepAliveClientMixin {
  bool _isCollapsed = true;
  bool _isExpanded = false;
  late final ScrollController _sheetScrollController;

  @override
  void initState() {
    super.initState();
    _sheetScrollController = ScrollController();
  }

  @override
  void dispose() {
    _sheetScrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _handleSelectSession(
    BuildContext context,
    Session session,
  ) {
    context.read<SessionSelectorCubit>().selectSession(session);
    _setSheetExpanded(false);

    // Ensure the sheet content starts from the top when reopening.
    if (_sheetScrollController.hasClients) {
      _sheetScrollController.jumpTo(0);
    }
  }

  void _setSheetExpanded(bool expanded) {
    if (_isExpanded == expanded && _isCollapsed == !expanded) return;
    setState(() {
      _isExpanded = expanded;
      _isCollapsed = !expanded;
    });
    widget.onSheetExpanded?.call(expanded);
  }

  void _toggleSheet() {
    _setSheetExpanded(!_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    // keepAlive: preserve state when parent swaps children.
    super.build(context);
    return BlocProvider(
      create: (context) {
        final cubit = SessionSelectorCubit(
          eventID: widget.eventID,
          eventsRepository: context.read<EventsRepository>(),
        );

        unawaited(cubit.loadEvent());
        return cubit;
      },
      child: BlocBuilder<SessionSelectorCubit, SessionSelectorState>(
        builder: (context, state) {
          final selectedSession = state.selectedSession;
          final selectedRoomName = state.selectedRoomName;

          return SessionsLayout(
            isExpanded: _isExpanded,
            selectorSheet: Builder(
              builder: (context) {
                if (state.errorMessage != null) {
                  return _ErrorSelectorSheet(
                    message: state.errorMessage!,
                    onRetry: context.read<SessionSelectorCubit>().loadEvent,
                    scrollController: _sheetScrollController,
                    fillsExpandedViewport: _isExpanded,
                  );
                }

                if (state.rooms.isEmpty && state.loading) {
                  return _LoadingSelectorSheet(
                    scrollController: _sheetScrollController,
                    fillsExpandedViewport: _isExpanded,
                  );
                }

                return SessionSelectorSheet(
                  rooms: state.rooms,
                  selectedSessionID: state.selectedSessionId ?? '',
                  selectedSession: state.selectedSession,
                  isCollapsed: _isCollapsed,
                  isExpanded: _isExpanded,
                  onTapHeader: _toggleSheet,
                  onSelectSession: (session) =>
                      _handleSelectSession(context, session),
                  scrollController: _sheetScrollController,
                );
              },
            ),
            sessionContent: selectedSession != null && selectedRoomName != null
                ? BlocProvider(
                    key: ValueKey<String>(selectedSession.id),
                    create: (context) => SessionStatusCubit(
                      eventID: widget.eventID,
                      sessionID: selectedSession.id,
                      eventsRepository: context.read<EventsRepository>(),
                    )..loadUnawaited(),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bottomSafe = MediaQuery.paddingOf(context).bottom;
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: bottomSafe + 12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Quick actions only use intrinsic height.
                                BlocBuilder<
                                  SessionStatusCubit,
                                  SessionStatusState
                                >(
                                  builder: (context, statusState) {
                                    final effective =
                                        statusState.session ?? selectedSession;
                                    if (effective.status ==
                                            SessionStatus.completed ||
                                        effective.status ==
                                            SessionStatus.canceled) {
                                      return const SizedBox.shrink();
                                    }
                                    final isLive =
                                        effective.status == SessionStatus.live;
                                    final disableStatusChange =
                                        statusState.loading ||
                                        statusState.updating;
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        16,
                                        20,
                                        12,
                                      ),
                                      child: _QuickActionsCard(
                                        isLive: isLive,
                                        disableStatusChange:
                                            disableStatusChange,
                                        eventID: widget.eventID,
                                        sessionID: selectedSession.id,
                                      ),
                                    );
                                  },
                                ),
                                SelectedSessionPanel(
                                  key: ValueKey<String>(selectedSession.id),
                                  eventID: widget.eventID,
                                  roomName: selectedRoomName,
                                  session: selectedSession,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : state.loading
                ? const _SelectedSessionLoadingPanel()
                : const _SelectedSessionEmptyPanel(),
          );
        },
      ),
    );
  }
}

final class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.isLive,
    required this.disableStatusChange,
    required this.eventID,
    required this.sessionID,
  });

  final bool isLive;
  final bool disableStatusChange;
  final String eventID;
  final String sessionID;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (isLive) ...[
              SessionCheckInButton(
                key: ValueKey<String>('session-check-in-$sessionID'),
                eventID: eventID,
                sessionID: sessionID,
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ReleaseUncheckedInBookingsButton(
                        key: ValueKey<String>('release-unchecked-$sessionID'),
                        eventID: eventID,
                        sessionID: sessionID,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChangeSessionStatusButton(
                        targetStatus: SessionStatus.completed,
                        disabled: disableStatusChange,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _ChangeSessionStatusButton(
                targetStatus: SessionStatus.live,
                disabled: disableStatusChange,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _ReleaseUncheckedInBookingsButton extends StatefulWidget {
  const _ReleaseUncheckedInBookingsButton({
    required this.eventID,
    required this.sessionID,
    super.key,
  });

  final String eventID;
  final String sessionID;

  @override
  State<_ReleaseUncheckedInBookingsButton> createState() =>
      _ReleaseUncheckedInBookingsButtonState();
}

final class _ReleaseUncheckedInBookingsButtonState
    extends State<_ReleaseUncheckedInBookingsButton> {
  bool _loading = false;

  Future<void> _confirmAndRelease() async {
    final eventsRepository = context.read<EventsRepository>();
    final shouldRelease = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Release unchecked-in bookings?'),
          content: const Text(
            'This will release all bookings for attendees who have not '
            'checked in to this live session.',
          ),
          actions: [
            TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(dialogContext).pop(true),
              child: const Text('Release bookings'),
            ),
          ],
        );
      },
    );

    if (shouldRelease != true) return;
    setState(() => _loading = true);

    try {
      final released = await eventsRepository.releaseUncheckedInSessionBookings(
        eventID: widget.eventID,
        sessionID: widget.sessionID,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('Released $released bookings'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } on EventsFailure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(failure.toDisplayMessage()),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: _loading ? null : _confirmAndRelease,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      icon: Icon(
        Icons.restore_rounded,
        size: 22,
        color: theme.colorScheme.onPrimary,
      ),
      label: Text(
        _loading ? 'Releasing…' : 'Release unchecked-in bookings',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

final class _ChangeSessionStatusButton extends StatelessWidget {
  const _ChangeSessionStatusButton({
    required this.targetStatus,
    required this.disabled,
  });

  final SessionStatus targetStatus;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, icon) = switch (targetStatus) {
      SessionStatus.live => ('Set to live', Icons.play_circle_fill_rounded),
      SessionStatus.completed => (
        'Mark completed',
        Icons.check_circle_outline_rounded,
      ),
      _ => ('Change status', Icons.swap_horiz_rounded),
    };

    return FilledButton.icon(
      onPressed: disabled
          ? null
          : () => context.read<SessionStatusCubit>().changeStatus(targetStatus),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      icon: Icon(
        icon,
        size: 22,
        color: theme.colorScheme.onPrimary,
      ),
      label: Text(
        disabled ? 'Working…' : label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

final class _SelectedSessionEmptyPanel extends StatelessWidget {
  const _SelectedSessionEmptyPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 280),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Session',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Select a session from the dropdown above '
                'to manage the session.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.keyboard_double_arrow_down_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Open the sessions list, then tap a session.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SelectedSessionLoadingPanel extends StatelessWidget {
  const _SelectedSessionLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 280),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Session',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Loading sessions...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

final class _LoadingSelectorSheet extends StatelessWidget {
  const _LoadingSelectorSheet({
    required this.scrollController,
    required this.fillsExpandedViewport,
  });

  final ScrollController scrollController;
  final bool fillsExpandedViewport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      shrinkWrap: !fillsExpandedViewport,
      physics: fillsExpandedViewport
          ? null
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a session',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _ErrorSelectorSheet extends StatelessWidget {
  const _ErrorSelectorSheet({
    required this.message,
    required this.onRetry,
    required this.scrollController,
    required this.fillsExpandedViewport,
  });

  final String message;
  final VoidCallback onRetry;
  final ScrollController scrollController;
  final bool fillsExpandedViewport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      shrinkWrap: !fillsExpandedViewport,
      physics: fillsExpandedViewport
          ? null
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Could not load sessions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
