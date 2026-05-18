import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/local_storage/database/database_health_check.dart';
import 'package:tag/core/local_storage/file_store/local_file_store.dart';
import 'package:tag/core/navigation/presentation/placeholder_route_screen.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderRouteScreen(
      title: 'Settings',
      description: 'Local data and device settings will live here later.',
      children: [
        if (kDebugMode) ...const [
          _DatabaseHealthPanel(),
          SizedBox(height: 12),
          _FileStoreHealthPanel(),
        ],
      ],
    );
  }
}

class _DatabaseHealthPanel extends StatelessWidget {
  const _DatabaseHealthPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<DatabaseHealthStatus>(
      future: locator<DatabaseHealthCheck>().check(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isHealthy = status?.isHealthy ?? false;
        final title = switch (snapshot.connectionState) {
          ConnectionState.waiting => 'Checking database...',
          _ when isHealthy => 'Database healthy',
          _ => 'Database needs attention',
        };
        final detail = switch (status) {
          null => 'Opening the local SQLite store.',
          _ when status.isHealthy =>
            'Schema v${status.schemaVersion} - '
                '${status.tableNames.length} local tables ready',
          _ => status.errorMessage ?? 'Database health check failed.',
        };

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FileStoreHealthPanel extends StatelessWidget {
  const _FileStoreHealthPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<LocalFileStoreStatus>(
      future: locator<LocalFileStore>().checkStatus(),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final isHealthy = status?.isHealthy ?? false;
        final title = switch (snapshot.connectionState) {
          ConnectionState.waiting => 'Checking file store...',
          _ when isHealthy => 'File store healthy',
          _ => 'File store needs attention',
        };
        final detail = switch (status) {
          null => 'Preparing app-owned source storage.',
          _ when status.isHealthy =>
            '${status.readyDirectoryCount} local directories ready: '
                '${status.requiredDirectoryLabels.join(', ')}',
          _ => status.errorMessage ?? 'File store health check failed.',
        };

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
