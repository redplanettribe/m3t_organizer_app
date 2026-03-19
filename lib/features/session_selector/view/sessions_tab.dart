import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/session_check_in/session_check_in.dart';
import 'package:m3t_organizer/features/session_selector/bloc/session_selector_cubit.dart';
import 'package:m3t_organizer/features/session_selector/view/session_selector_sheet.dart';
import 'package:m3t_organizer/features/session_status/session_status.dart';

final class SessionsTab extends StatefulWidget {
  const SessionsTab({
    required this.eventID,
    this.onSheetExpanded,
    super.key,
  });

  final String eventID;
  final ValueChanged<bool>? onSheetExpanded;

  @override
  State<SessionsTab> createState() => _SessionsTabState();
}

final class _SessionsTabState extends State<SessionsTab>
    with AutomaticKeepAliveClientMixin {
  static const double _minChildSize = 0.18;
  static const double _initialChildSize = 0.34;

  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  bool _isCollapsed = false;
  bool _isExpanded = false;
  ScrollController? _sheetScrollController;

  @override
  bool get wantKeepAlive => true;

  void _handleSelectSession(
    BuildContext context,
    Session session,
  ) {
    context.read<SessionSelectorCubit>().selectSession(session);

    // Update UI immediately; the draggable sheet will animate to min size.
    if (!_isCollapsed) {
      setState(() {
        _isCollapsed = true;
      });
    }

    // Ensure the sheet content starts from the top when reopening.
    if (_sheetScrollController?.hasClients ?? false) {
      _sheetScrollController!.jumpTo(0);
    }

    // Collapse the drawer after selecting.
    unawaited(
      _draggableController.animateTo(
        _minChildSize,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Keep this tab alive across TabBarView switches.
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

          return Stack(
            children: [
              if (selectedSession != null && selectedRoomName != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: SessionCheckInButton(
                        key: ValueKey<String>(
                          'session-check-in-${selectedSession.id}',
                        ),
                        eventID: widget.eventID,
                        sessionID: selectedSession.id,
                      ),
                    ),
                    Expanded(
                      child: SelectedSessionPanel(
                        key: ValueKey<String>(selectedSession.id),
                        eventID: widget.eventID,
                        roomName: selectedRoomName,
                        session: selectedSession,
                      ),
                    ),
                  ],
                )
              else if (state.loading)
                const _SelectedSessionLoadingPanel()
              else
                const _SelectedSessionEmptyPanel(),
              ClipRect(
                child: NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    final shouldCollapse =
                        notification.extent <= (_minChildSize + 0.01);
                    final shouldExpand = notification.extent >= 0.95;

                    final collapsedChanged = shouldCollapse != _isCollapsed;
                    final expandedChanged = shouldExpand != _isExpanded;

                    if (collapsedChanged || expandedChanged) {
                      setState(() {
                        _isCollapsed = shouldCollapse;
                        _isExpanded = shouldExpand;
                      });
                      if (expandedChanged) {
                        widget.onSheetExpanded?.call(shouldExpand);
                      }
                    }
                    return false;
                  },
                  child: DraggableScrollableSheet(
                    controller: _draggableController,
                    minChildSize: _minChildSize,
                    initialChildSize: _initialChildSize,
                    snap: true,
                    snapSizes: const [_initialChildSize],
                    builder: (context, scrollController) {
                      _sheetScrollController = scrollController;

                      if (state.errorMessage != null) {
                        return _ErrorSelectorSheet(
                          message: state.errorMessage!,
                          onRetry:
                              context.read<SessionSelectorCubit>().loadEvent,
                          scrollController: scrollController,
                        );
                      }

                      if (state.rooms.isEmpty && state.loading) {
                        return _LoadingSelectorSheet(
                          scrollController: scrollController,
                        );
                      }

                      return SessionSelectorSheet(
                        rooms: state.rooms,
                        selectedSessionID: state.selectedSessionId ?? '',
                        selectedSession: state.selectedSession,
                        isCollapsed: _isCollapsed,
                        isExpanded: _isExpanded,
                        onSelectSession: (session) =>
                            _handleSelectSession(context, session),
                        scrollController: scrollController,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
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
                'Select a session from the drawer below to start check-in '
                'and manage the flow.',
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
  const _LoadingSelectorSheet({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
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
  });

  final String message;
  final VoidCallback onRetry;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
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
