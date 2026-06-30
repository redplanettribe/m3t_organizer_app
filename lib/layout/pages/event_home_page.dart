import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/event_selector/event_selector.dart';
import 'package:m3t_organizer/features/user/view/user_avatar_button.dart';
import 'package:m3t_organizer/layout/pages/event_workspace_scaffold.dart';

/// Home screen: selected event workspace with avatar + event selector app bar.
final class EventHomePage extends StatelessWidget {
  const EventHomePage({super.key});

  PreferredSizeWidget _buildAppBar({required bool dropdownEnabled}) {
    return AppBar(
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: UserAvatarButton(),
      ),
      title: EventSelectorDropdown(enabled: dropdownEnabled),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedEventCubit, SelectedEventState>(
      builder: (context, state) {
        if (state.loading) {
          return Scaffold(
            appBar: _buildAppBar(dropdownEnabled: false),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.errorMessage != null) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: _buildAppBar(dropdownEnabled: false),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 44,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: context.read<SelectedEventCubit>().loadEvents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.events.isEmpty || state.selectedEvent == null) {
          final theme = Theme.of(context);
          return Scaffold(
            appBar: _buildAppBar(dropdownEnabled: false),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 44,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No events yet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Events you are a team member of will show up here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final selectedEvent = state.selectedEvent!;

        return EventWorkspaceScaffold(
          key: ValueKey(selectedEvent.id),
          eventID: selectedEvent.id,
          appBar: _buildAppBar(dropdownEnabled: true),
        );
      },
    );
  }
}
