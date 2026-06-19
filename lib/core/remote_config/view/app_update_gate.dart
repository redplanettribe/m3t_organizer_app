import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3t_organizer/app/theme/app_theme.dart';
import 'package:m3t_organizer/core/remote_config/remote_config_cubit.dart';
import 'package:m3t_organizer/core/remote_config/view/force_update_page.dart';

final class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

final class _AppUpdateGateState extends State<AppUpdateGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<RemoteConfigCubit>().checkUnawaited();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
      builder: (context, state) {
        if (state.status == RemoteConfigStatus.forced &&
            state.updateUrl != null) {
          return MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: ForceUpdatePage(
              updateUrl: state.updateUrl!,
              minVersion: state.minVersion,
              latestVersion: state.latestVersion,
            ),
          );
        }
        return widget.child;
      },
    );
  }
}
