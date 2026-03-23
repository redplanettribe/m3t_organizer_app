import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_organizer/app/bloc/auth_bloc.dart';
import 'package:m3t_organizer/app/routes.dart';
import 'package:m3t_organizer/core/legal/privacy_policy_url.dart';
import 'package:m3t_organizer/features/user/bloc/user_cubit.dart';
import 'package:m3t_organizer/features/user/view/user_avatar.dart';
import 'package:m3t_organizer/features/user/view/user_qr_code.dart';
import 'package:m3t_organizer/features/user/view/user_view_helpers.dart';
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;

/// User profile configuration page.
///
/// Displays the user's avatar, their organizer QR code (primary event
/// credential), navigation to profile editing, logout, and account deletion.
/// All navigation uses [AppRoutes] — no raw string literals.
final class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

final class _ConfigPageState extends State<ConfigPage> {
  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(PrivacyPolicyUrl.url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception catch (_) {
      await launchUrl(uri);
    }
  }

  Future<void> _confirmAndDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'Your account will be closed and personal data removed. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      ),
    );

    try {
      await context.read<UserCubit>().deleteAccount();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    if (!mounted) return;
    final message = context.read<UserCubit>().state.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dangerColor = colorScheme.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              final busy = state.deletingAccount;
              return SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatar(user: state.user, radius: 64),
                      if (state.user.displayName != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          state.user.displayName!,
                          style: textTheme.titleLarge,
                        ),
                      ],
                      if (state.user != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          state.user!.email,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (state.user != null) ...[
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          onPressed: busy
                              ? null
                              : () => showUserQrCodeSheet(
                                  context,
                                  userId: state.user!.id,
                                ),
                          icon: const Icon(Icons.qr_code),
                          label: const Text('View QR'),
                        ),
                        const SizedBox(height: 32),
                      ],
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Update profile'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: busy
                            ? null
                            : () => context.push(AppRoutes.updateUser),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy Policy'),
                        onTap: () => unawaited(_openPrivacyPolicy()),
                      ),
                      ListTile(
                        leading: Icon(Icons.logout, color: dangerColor),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: dangerColor),
                        ),
                        onTap: busy
                            ? null
                            : () => context.read<AuthBloc>().add(
                                const AuthLogoutRequested(),
                              ),
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_forever, color: dangerColor),
                        title: Text(
                          'Delete account',
                          style: TextStyle(color: dangerColor),
                        ),
                        onTap: busy ? null : _confirmAndDeleteAccount,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
