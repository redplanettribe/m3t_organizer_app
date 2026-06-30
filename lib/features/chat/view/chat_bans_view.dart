import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:m3t_organizer/features/chat/bloc/chat_bans_cubit.dart';

final class ChatBansView extends StatelessWidget {
  const ChatBansView({required this.eventID, super.key});

  final String eventID;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBansCubit(
        chatRepository: context.read<ChatRepository>(),
        eventsRepository: context.read<EventsRepository>(),
        eventID: eventID,
      ),
      child: BlocListener<ChatBansCubit, ChatBansState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ChatBansToolbar(),
            Expanded(child: _ChatBansList()),
          ],
        ),
      ),
    );
  }
}

final class _ChatBansToolbar extends StatelessWidget {
  const _ChatBansToolbar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        children: [
          Text(
            'Banned attendees',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Ban attendee',
            icon: const Icon(Icons.person_add_disabled_outlined),
            onPressed: () => _showBanAttendeeSheet(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showBanAttendeeSheet(BuildContext context) async {
    final cubit = context.read<ChatBansCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: const _BanAttendeeSheet(),
        );
      },
    );
  }
}

final class _ChatBansList extends StatelessWidget {
  const _ChatBansList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<ChatBansCubit>();

    return BlocBuilder<ChatBansCubit, ChatBansState>(
      builder: (context, state) {
        if (state.status == ChatBansStatus.loading && state.bans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ChatBansStatus.failure && state.bans.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.errorMessage ?? 'Could not load banned attendees.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: cubit.loadInitial,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.bans.isEmpty) {
          return RefreshIndicator(
            onRefresh: cubit.refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.35,
                  child: Center(
                    child: Text(
                      'No banned attendees for this event.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: cubit.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: state.bans.length + (state.hasMorePages ? 1 : 0),
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= state.bans.length) {
                return _LoadMoreTile(
                  loading: state.loadingMore,
                  onLoadMore: cubit.loadMore,
                );
              }

              final ban = state.bans[index];
              return _BanListTile(ban: ban);
            },
          ),
        );
      },
    );
  }
}

final class _BanListTile extends StatelessWidget {
  const _BanListTile({required this.ban});

  final ChatBan ban;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = [
      ban.userName,
      ban.userLastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final label = name.isNotEmpty ? name : ban.userId;
    final bannedBy = [
      ban.bannedByName,
      ban.bannedByLastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final bannedAt = ban.bannedAt != null
        ? DateFormat.yMMMd().add_jm().format(ban.bannedAt!.toLocal())
        : null;

    final subtitleParts = <String>[
      if (bannedBy.isNotEmpty) 'Banned by $bannedBy',
      ?bannedAt,
      ban.userId,
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(
        subtitleParts.join(' · '),
        style: theme.textTheme.bodySmall,
      ),
      trailing: IconButton(
        tooltip: 'Unban',
        icon: const Icon(Icons.undo_outlined),
        onPressed: () => _confirmUnban(context, ban),
      ),
    );
  }

  Future<void> _confirmUnban(BuildContext context, ChatBan ban) async {
    final name = [
      ban.userName,
      ban.userLastName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final label = name.isNotEmpty ? name : ban.userId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unban attendee'),
        content: Text('Allow $label to send chat messages again?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Unban'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (!context.mounted) return;
      await context.read<ChatBansCubit>().unbanUser(ban.userId);
    }
  }
}

final class _BanAttendeeSheet extends StatefulWidget {
  const _BanAttendeeSheet();

  @override
  State<_BanAttendeeSheet> createState() => _BanAttendeeSheetState();
}

final class _BanAttendeeSheetState extends State<_BanAttendeeSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<EventRegistration> _results = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      final results = await context.read<ChatBansCubit>().searchAttendees(
        value,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    });
  }

  Future<void> _banAttendee(EventRegistration registration) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ban from chat'),
        content: Text(
          'Ban ${registration.displayName} from sending chat messages?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ban'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      if (!mounted) return;
      await context.read<ChatBansCubit>().banUser(registration.userId);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final banningUserId = context.select<ChatBansCubit, String?>(
      (c) => c.state.banningUserId,
    );
    final bannedUserIds = context.select<ChatBansCubit, Set<String>>(
      (c) => c.state.bans.map((b) => b.userId).toSet(),
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ban attendee',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Search by name or email',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 12),
          if (_searching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchController.text.trim().isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Type to search registered attendees.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (_results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No attendees match your search.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final registration = _results[index];
                  final isBanned = bannedUserIds.contains(registration.userId);
                  final isBanning = banningUserId == registration.userId;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(registration.displayName),
                    subtitle: Text(
                      registration.email ?? registration.userId,
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: isBanned
                        ? Text(
                            'Banned',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : isBanning
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            tooltip: 'Ban',
                            icon: const Icon(Icons.block_outlined),
                            onPressed: () => _banAttendee(registration),
                          ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

final class _LoadMoreTile extends StatelessWidget {
  const _LoadMoreTile({
    required this.loading,
    required this.onLoadMore,
  });

  final bool loading;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Center(
      child: TextButton(
        onPressed: onLoadMore,
        child: const Text('Load more'),
      ),
    );
  }
}
