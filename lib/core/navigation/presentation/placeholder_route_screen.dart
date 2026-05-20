import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/utils/index.dart';

class PlaceholderRouteScreen extends StatelessWidget {
  const PlaceholderRouteScreen({
    required this.title,
    required this.description,
    this.children = const [],
    super.key,
  });

  final String title;
  final String description;
  final List<Widget> children;

  static const List<_RouteLink> _routeLinks = [
    _RouteLink('Splash', splashPath),
    _RouteLink('Onboarding', onboardingPath),
    _RouteLink('Model setup', modelSetupPath),
    _RouteLink('Today', todayPath),
    _RouteLink('Chat', chatPath),
    _RouteLink('Settings', settingsPath),
    _RouteLink('Beta feedback', betaFeedbackPath),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 28),
            ...children,
            if (children.isNotEmpty) const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final route in _routeLinks)
                      OutlinedButton(
                        onPressed: currentPath == route.path
                            ? null
                            : () => context.go(route.path),
                        child: Text(route.label),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteLink {
  const _RouteLink(this.label, this.path);

  final String label;
  final String path;
}
