import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({
    required this.updateUrl,
    this.minVersion,
    this.latestVersion,
    super.key,
  });

  final Uri updateUrl;
  final String? minVersion;
  final String? latestVersion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update required',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'This app version is no longer supported. '
                  'Update to continue.',
                  style: theme.textTheme.bodyLarge,
                ),
                if (minVersion != null || latestVersion != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    [
                      if (minVersion != null) 'Minimum: $minVersion',
                      if (latestVersion != null) 'Latest: $latestVersion',
                    ].join(' • '),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await launchUrl(
                        updateUrl,
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    child: const Text('Update now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
