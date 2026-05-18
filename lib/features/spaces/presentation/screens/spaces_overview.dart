import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/features/spaces/domain/entities/space_entities.dart';
import 'package:tag/features/spaces/presentation/logic/spaces_cubit.dart';
import 'package:tag/features/spaces/presentation/widgets/space_card_list_item.dart';
import 'package:tag/utils/index.dart';

class SpacesOverview extends StatelessWidget {
  const SpacesOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SpacesCubit>(
      create: (_) => locator<SpacesCubit>()..load(),
      child: const _SpacesOverviewBody(),
    );
  }
}

class _SpacesOverviewBody extends StatelessWidget {
  const _SpacesOverviewBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpacesCubit, SpacesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const _SpacesLoadingCard();
        }

        if (state.status == SpacesStatus.error) {
          return _SpacesMessageCard(
            icon: Icons.error_outline_rounded,
            title: 'Spaces could not load',
            message: state.errorMessage.isEmpty
                ? 'Tag could not read Space summaries from local storage.'
                : state.errorMessage,
          );
        }

        if (state.spaces.isEmpty) {
          return const _SpacesMessageCard(
            icon: Icons.space_dashboard_outlined,
            title: 'Spaces will appear as Tag understands what you save.',
            message:
                "They're not folders. They're the bigger contexts behind your cards.",
          );
        }

        return Column(
          children: [
            for (var index = 0; index < state.spaces.length; index++) ...[
              if (index > 0) const SizedBox(height: TagSpacing.s3),
              SpaceCardListItem(
                summary: state.spaces[index],
                onTap: () => _openSpace(context, state.spaces[index]),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _openSpace(
    BuildContext context,
    SpaceSummaryEntity summary,
  ) async {
    await context.read<SpacesCubit>().recordSpaceView(summary.space.id);
    if (!context.mounted) {
      return;
    }

    context.push(spaceDetailLocation(summary.space.id));
  }
}

class _SpacesLoadingCard extends StatelessWidget {
  const _SpacesLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s5),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.brandPrimary,
              ),
            ),
            const SizedBox(width: TagSpacing.s3),
            Text(
              'Reading Spaces',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpacesMessageCard extends StatelessWidget {
  const _SpacesMessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<TagThemeColors>()!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.brandSoftText, size: 28),
            const SizedBox(height: TagSpacing.s4),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: TagSpacing.s2),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
