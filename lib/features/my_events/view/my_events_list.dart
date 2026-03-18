import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/core/media/media_url_resolver.dart';
import 'package:m3t_organizer/features/my_events/bloc/my_events_cubit.dart';

/// Home-screen widget showing the current user's managed events.
final class MyEventsList extends StatelessWidget {
  const MyEventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyEventsCubit>(
      create: (context) {
        final cubit = MyEventsCubit(
          eventsRepository: context.read<EventsRepository>(),
        );
        unawaited(cubit.loadMyEvents());
        return cubit;
      },
      child: BlocBuilder<MyEventsCubit, MyEventsState>(
        builder: (context, state) {
          final dateFormat = DateFormat.yMMMd();
          final theme = Theme.of(context);

          if (state.loading) {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: 6,
              separatorBuilder: (context, _) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return const _EventCardSkeleton();
              },
            );
          }

          if (state.errorMessage != null) {
            return Center(
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
                      onPressed: () => context
                          .read<MyEventsCubit>()
                          .loadMyEvents(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.events.isEmpty) {
            return Center(
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
                      'No events managed yet.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your managed events will show up here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.events.length,
            separatorBuilder: (context, _) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _EventCard(
                event: state.events[index],
                dateFormat: dateFormat,
              );
            },
          );
        },
      ),
    );
  }
}

final class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.dateFormat,
  });

  final Event event;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final startDateText = event.startDate != null
        ? dateFormat.format(event.startDate!)
        : 'No start date';

    final durationText =
        event.durationDays != null ? '${event.durationDays} days' : null;

    final metaText = durationText != null
        ? '$startDateText - $durationText'
        : startDateText;

    final hasDescription = event.description != null &&
        event.description!.trim().isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _EventThumbnail(
              thumbnailUrl: event.thumbnailUrl,
              size: 74,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    metaText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasDescription) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description!.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _EventThumbnail extends StatelessWidget {
  const _EventThumbnail({
    required this.thumbnailUrl,
    required this.size,
  });

  final String? thumbnailUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedUrl = MediaUrlResolver.resolveAppUrl(thumbnailUrl);

    final borderRadius = BorderRadius.circular(14);

    final Widget placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.event,
        color: theme.colorScheme.onSurfaceVariant,
        size: size * 0.38,
      ),
    );

    if (resolvedUrl == null || resolvedUrl.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: placeholder,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Semantics(
        label: 'Event thumbnail',
        image: true,
        child: Image.network(
          resolvedUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            final expected = loadingProgress.expectedTotalBytes;
            final loaded = loadingProgress.cumulativeBytesLoaded;
            final value = expected != null && expected > 0
                ? loaded / expected
                : null;

            return Container(
              width: size,
              height: size,
              color: theme.colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 2.5,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return placeholder;
          },
        ),
      ),
    );
  }
}

final class _EventCardSkeleton extends StatelessWidget {
  const _EventCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget line(double w, {double h = 12}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  line(180),
                  const SizedBox(height: 10),
                  line(140),
                  const SizedBox(height: 10),
                  line(220, h: 10),
                  const SizedBox(height: 8),
                  line(200, h: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
