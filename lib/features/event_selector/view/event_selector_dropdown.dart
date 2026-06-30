import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/features/event_selector/bloc/selected_event_cubit.dart';

/// App-bar dropdown for switching between team events.
final class EventSelectorDropdown extends StatelessWidget {
  const EventSelectorDropdown({
    this.enabled = true,
    super.key,
  });

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedEventCubit, SelectedEventState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final selected = state.selectedEvent;
        final label = selected?.name ?? 'Select event';

        if (!enabled || state.events.isEmpty) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(
                  alpha: enabled ? 1 : 0.5,
                ),
              ),
            ),
          );
        }

        return PopupMenuButton<Event>(
          tooltip: 'Select event',
          enabled: enabled,
          onSelected: (event) {
            unawaited(context.read<SelectedEventCubit>().selectEvent(event));
          },
          itemBuilder: (context) {
            return state.events
                .map(
                  (event) => PopupMenuItem<Event>(
                    value: event,
                    child: Row(
                      children: [
                        if (event.id == selected?.id)
                          Icon(
                            Icons.check,
                            size: 18,
                            color: theme.colorScheme.primary,
                          )
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        );
      },
    );
  }
}
