import 'dart:async' show unawaited;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:m3t_organizer/app/bloc/auth_bloc.dart';
import 'package:m3t_organizer/app/router.dart';
import 'package:m3t_organizer/app/routes.dart';
import 'package:m3t_organizer/app/theme/app_theme.dart';
import 'package:m3t_organizer/core/remote_config/remote_config_cubit.dart';
import 'package:m3t_organizer/core/remote_config/view/app_update_gate.dart';
import 'package:m3t_organizer/features/login/login.dart';
import 'package:m3t_organizer/features/session_status/session_status.dart';
import 'package:m3t_organizer/features/user/user.dart';
import 'package:m3t_organizer/layout/layout.dart';

// ---------------------------------------------------------------------------
// App root
// ---------------------------------------------------------------------------

/// Root widget. Owns the repository and BLoC composition.
final class App extends StatelessWidget {
  const App({
    required AuthRepository authRepository,
    required EventsRepository eventsRepository,
    required RemoteConfigRepository remoteConfigRepository,
    required int? currentBuild,
    required MobileAppPlatform remoteConfigPlatform,
    required bool useIosStoreUrl,
    super.key,
  }) : _authRepository = authRepository,
       _eventsRepository = eventsRepository,
       _remoteConfigRepository = remoteConfigRepository,
       _currentBuild = currentBuild,
       _remoteConfigPlatform = remoteConfigPlatform,
       _useIosStoreUrl = useIosStoreUrl;

  final AuthRepository _authRepository;
  final EventsRepository _eventsRepository;
  final RemoteConfigRepository _remoteConfigRepository;
  final int? _currentBuild;
  final MobileAppPlatform _remoteConfigPlatform;
  final bool _useIosStoreUrl;

  @override
  Widget build(BuildContext context) {
    final currentBuild = _currentBuild;
    return RepositoryProvider<AuthRepository>.value(
      value: _authRepository,
      child: RepositoryProvider<EventsRepository>.value(
        value: _eventsRepository,
        child: RepositoryProvider<RemoteConfigRepository>.value(
          value: _remoteConfigRepository,
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(authRepository: context.read()),
              ),
              BlocProvider<UserCubit>(
                create: (context) {
                  final cubit = UserCubit(authRepository: context.read());
                  unawaited(cubit.loadCurrentUser());
                  return cubit;
                },
              ),
              if (currentBuild != null)
                BlocProvider<RemoteConfigCubit>(
                  create: (context) => RemoteConfigCubit(
                    remoteConfigRepository: context.read(),
                    currentBuild: currentBuild,
                    app: 'organizer',
                    platform: _remoteConfigPlatform,
                    useIosStoreUrl: _useIosStoreUrl,
                  ),
                ),
            ],
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                switch (state.status) {
                  case .authenticated:
                    unawaited(context.read<UserCubit>().loadCurrentUser());
                  case .unauthenticated:
                    context.read<UserCubit>().reset();
                  case .unknown:
                    break;
                }
              },
              child: currentBuild == null
                  ? const _AppView()
                  : const AppUpdateGate(child: _AppView()),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _AppView (router host)
// ---------------------------------------------------------------------------

final class _AppView extends StatefulWidget {
  const _AppView();

  @override
  State<_AppView> createState() => _AppViewState();
}

final class _AppViewState extends State<_AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();

    _router = GoRouter(
      refreshListenable: GoRouterRefreshStream<AuthState>(authBloc.stream),
      redirect: (_, routerState) {
        final authStatus = authBloc.state.status;
        final isOnLogin = routerState.matchedLocation == AppRoutes.login;

        return switch (authStatus) {
          .authenticated when isOnLogin => AppRoutes.home,
          .unauthenticated when !isOnLogin => AppRoutes.login,
          _ => null,
        };
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.event,
          builder: (context, state) {
            final eventID = state.pathParameters['eventID'] ?? '';
            final extra = state.extra;
            final event = extra is Event ? extra : null;
            return OrganizerEventPage(
              eventID: eventID,
              eventName: event?.name,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.config,
          builder: (context, state) => const ConfigPage(),
          routes: [
            GoRoute(
              path: AppRoutes.updateUserSegment,
              builder: (context, state) => const UpdateUserPage(),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.speaker,
          builder: (context, state) {
            final speaker = state.extra! as Speaker;
            return SpeakerDetailPage(speaker: speaker);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'm3t Organizer',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: _router,
    );
  }
}
