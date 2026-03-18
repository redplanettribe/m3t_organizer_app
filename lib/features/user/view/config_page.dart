import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_organizer/app/bloc/auth_bloc.dart';
import 'package:m3t_organizer/app/routes.dart';
import 'package:m3t_organizer/features/user/bloc/user_cubit.dart';
import 'package:m3t_organizer/features/user/view/user_avatar.dart';
import 'package:m3t_organizer/features/user/view/user_qr_code.dart';
import 'package:m3t_organizer/features/user/view/user_view_helpers.dart';

/// User profile configuration page.
///
/// Displays the user's avatar, their organizer QR code (primary event
/// credential), navigation to profile editing, and logout. All navigation
/// uses [AppRoutes] — no raw string literals.
final class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

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
              return SingleChildScrollView(
                child: Align(
                  alignment: .topCenter,
                  child: Column(
                    mainAxisSize: .min,
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
                          onPressed: () => showUserQrCodeSheet(
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
                        onTap: () => context.push(AppRoutes.updateUser),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.logout, color: dangerColor),
                        title: Text(
                          'Logout',
                          style: TextStyle(color: dangerColor),
                        ),
                        onTap: () => context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        ),
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
