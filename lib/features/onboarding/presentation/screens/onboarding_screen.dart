import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tag/core/DI/di.dart';
import 'package:tag/core/navigation/route_constants.dart';
import 'package:tag/core/startup/app_cubit.dart';
import 'package:tag/core/use_cases/use_cases.dart';
import 'package:tag/features/onboarding/presentation/logic/onboarding_cubit.dart';
import 'package:tag/features/source_ingestion/index.dart';
import 'package:tag/utils/index.dart';

TagThemeColors _tagColors(BuildContext context) {
  return Theme.of(context).extension<TagThemeColors>()!;
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (_) => locator<OnboardingCubit>()..load(),
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == OnboardingStatus.completed,
        listener: (context, state) {
          context.read<AppCubit>().startModelPreparation();
          _importPendingSharesAfterOnboarding();
          context.go(todayPath);
        },
        child: const _OnboardingView(),
      ),
    );
  }
}

void _importPendingSharesAfterOnboarding() {
  if (!locator.isRegistered<ImportPendingSharedSources>()) {
    return;
  }

  unawaited(
    locator<ImportPendingSharedSources>()
        .call(const NoParams())
        .catchError((Object _) => const <SourceItemEntity>[]),
  );
}

class _OnboardingView extends StatelessWidget {
  const _OnboardingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                TagSpacing.s5,
                TagSpacing.s4,
                TagSpacing.s5,
                TagSpacing.s8,
              ),
              children: [
                _StepDots(step: state.step, furthestStep: state.furthestStep),
                const SizedBox(height: TagSpacing.s8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _StepBody(key: ValueKey(state.step), state: state),
                ),
                if (state.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: TagSpacing.s5),
                  Text(
                    state.errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.state, super.key});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.step) {
      OnboardingStep.welcome => const _WelcomeStep(),
      OnboardingStep.nickname => _NicknameStep(state: state),
      OnboardingStep.avatar => _AvatarStep(state: state),
      OnboardingStep.localFirst => _LocalFirstStep(state: state),
      OnboardingStep.notifications => _NotificationsStep(state: state),
      OnboardingStep.share => _ShareStep(state: state),
    };
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Welcome to Tag',
      body:
          'Save things now. Act on them later.\n\nNever lose the reason you saved something.',
      action: FilledButton(
        key: const ValueKey('onboarding_start_button'),
        onPressed: () =>
            context.read<OnboardingCubit>().goToStep(OnboardingStep.nickname),
        child: const Text('Start'),
      ),
      children: const [_IndexCardIllustration()],
    );
  }
}

class _NicknameStep extends StatefulWidget {
  const _NicknameStep({required this.state});

  final OnboardingState state;

  @override
  State<_NicknameStep> createState() => _NicknameStepState();
}

class _NicknameStepState extends State<_NicknameStep> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.state.nickname);
  }

  @override
  void didUpdateWidget(covariant _NicknameStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.nickname != _controller.text) {
      _controller.text = widget.state.nickname;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'What should Tag call you?',
      body: 'No account, email, or sync setup. Just a local nickname for chat.',
      action: FilledButton(
        key: const ValueKey('nickname_continue_button'),
        onPressed: widget.state.isBusy
            ? null
            : context.read<OnboardingCubit>().saveNicknameAndContinue,
        child: Text(widget.state.isBusy ? 'Saving' : 'Continue'),
      ),
      children: [
        TextField(
          key: const ValueKey('nickname_field'),
          controller: _controller,
          enabled: !widget.state.isBusy,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nickname',
            hintText: 'Alex',
            border: OutlineInputBorder(),
          ),
          onChanged: context.read<OnboardingCubit>().updateNickname,
          onSubmitted: (_) =>
              context.read<OnboardingCubit>().saveNicknameAndContinue(),
        ),
      ],
    );
  }
}

class _AvatarStep extends StatefulWidget {
  const _AvatarStep({required this.state});

  static const avatars = [
    _AvatarChoice(
      value: 'memoji_02',
      assetPath: 'assets/onboarding/avatars/memoji_02.png',
      backgroundColor: Color(0xFFE6F0FF),
      label: 'Avatar option 1',
    ),
    _AvatarChoice(
      value: 'memoji_24',
      assetPath: 'assets/onboarding/avatars/memoji_24.png',
      backgroundColor: Color(0xFFEDE9FE),
      label: 'Avatar option 2',
    ),
    _AvatarChoice(
      value: 'memoji_01',
      assetPath: 'assets/onboarding/avatars/memoji_01.png',
      backgroundColor: Color(0xFFEFEEE8),
      label: 'Avatar option 3',
    ),
    _AvatarChoice(
      value: 'memoji_06',
      assetPath: 'assets/onboarding/avatars/memoji_06.png',
      backgroundColor: Color(0xFFDDF7F1),
      label: 'Avatar option 4',
    ),
    _AvatarChoice(
      value: 'memoji_18',
      assetPath: 'assets/onboarding/avatars/memoji_18.png',
      backgroundColor: Color(0xFFE5EDFF),
      label: 'Avatar option 5',
    ),
    _AvatarChoice(
      value: 'memoji_08',
      assetPath: 'assets/onboarding/avatars/memoji_08.png',
      backgroundColor: Color(0xFFFFE8D6),
      label: 'Avatar option 6',
    ),
    _AvatarChoice(
      value: 'memoji_12',
      assetPath: 'assets/onboarding/avatars/memoji_12.png',
      backgroundColor: Color(0xFFF7E8D3),
      label: 'Avatar option 7',
    ),
    _AvatarChoice(
      value: 'memoji_13',
      assetPath: 'assets/onboarding/avatars/memoji_13.png',
      backgroundColor: Color(0xFFDBEAFE),
      label: 'Avatar option 8',
    ),
    _AvatarChoice(
      value: 'memoji_20',
      assetPath: 'assets/onboarding/avatars/memoji_20.png',
      backgroundColor: Color(0xFFFFE4E6),
      label: 'Avatar option 9',
    ),
    _AvatarChoice(
      value: 'memoji_15',
      assetPath: 'assets/onboarding/avatars/memoji_15.png',
      backgroundColor: Color(0xFFF3E8FF),
      label: 'Avatar option 10',
    ),
    _AvatarChoice(
      value: 'memoji_05',
      assetPath: 'assets/onboarding/avatars/memoji_05.png',
      backgroundColor: Color(0xFFE4F4F5),
      label: 'Avatar option 11',
    ),
    _AvatarChoice(
      value: 'memoji_23',
      assetPath: 'assets/onboarding/avatars/memoji_23.png',
      backgroundColor: Color(0xFFFFF1D6),
      label: 'Avatar option 12',
    ),
  ];

  final OnboardingState state;

  @override
  State<_AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<_AvatarStep> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = _avatarIndexFor(widget.state.avatarValue);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.68,
    );
  }

  @override
  void didUpdateWidget(covariant _AvatarStep oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextIndex = _avatarIndexFor(widget.state.avatarValue);
    if (nextIndex == _currentIndex) {
      return;
    }

    _currentIndex = nextIndex;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(nextIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _avatarIndexFor(String value) {
    final index = _AvatarStep.avatars.indexWhere(
      (avatar) => avatar.value == value,
    );

    if (index >= 0) {
      return index;
    }

    final defaultIndex = _AvatarStep.avatars.indexWhere(
      (avatar) => avatar.value == OnboardingState.defaultAvatar,
    );

    return defaultIndex < 0 ? 0 : defaultIndex;
  }

  void _selectIndex(int index) {
    if (widget.state.isBusy ||
        index < 0 ||
        index >= _AvatarStep.avatars.length) {
      return;
    }

    setState(() => _currentIndex = index);
    context.read<OnboardingCubit>().updateAvatar(
      _AvatarStep.avatars[index].value,
    );
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  void _saveSelectedAvatar() {
    final cubit = context.read<OnboardingCubit>();
    final selectedValue = _AvatarStep.avatars[_currentIndex].value;
    if (widget.state.avatarValue != selectedValue) {
      cubit.updateAvatar(selectedValue);
    }
    cubit.saveAvatarAndContinue();
  }

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Choose an avatar.',
      body: 'Pick a simple local avatar for your Tag profile.',
      action: OutlinedButton.icon(
        onPressed: widget.state.isBusy ? null : _saveSelectedAvatar,
        icon: const Icon(Icons.check_rounded),
        label: Text(widget.state.isBusy ? 'Saving' : 'Use selected'),
      ),
      children: [
        SizedBox(
          height: 238,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                key: const ValueKey('avatar_slider'),
                controller: _pageController,
                physics: widget.state.isBusy
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: _AvatarStep.avatars.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  context.read<OnboardingCubit>().updateAvatar(
                    _AvatarStep.avatars[index].value,
                  );
                },
                itemBuilder: (context, index) {
                  final avatar = _AvatarStep.avatars[index];
                  return _AvatarSlide(
                    key: ValueKey('avatar_${avatar.value}'),
                    avatar: avatar,
                    selected: index == _currentIndex,
                  );
                },
              ),
              Positioned(
                left: 0,
                child: _AvatarNavButton(
                  key: const ValueKey('avatar_previous_button'),
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Previous avatar',
                  onPressed: widget.state.isBusy || _currentIndex == 0
                      ? null
                      : () => _selectIndex(_currentIndex - 1),
                ),
              ),
              Positioned(
                right: 0,
                child: _AvatarNavButton(
                  key: const ValueKey('avatar_next_button'),
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Next avatar',
                  onPressed:
                      widget.state.isBusy ||
                          _currentIndex == _AvatarStep.avatars.length - 1
                      ? null
                      : () => _selectIndex(_currentIndex + 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TagSpacing.s4),
        Center(
          child: _AvatarPositionDots(
            currentIndex: _currentIndex,
            itemCount: _AvatarStep.avatars.length,
          ),
        ),
      ],
    );
  }
}

class _AvatarNavButton extends StatelessWidget {
  const _AvatarNavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = _tagColors(context);

    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          shape: BoxShape.circle,
          border: Border.all(color: colors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: colors.textPrimary,
          disabledColor: colors.textTertiary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _AvatarChoice {
  const _AvatarChoice({
    required this.value,
    required this.assetPath,
    required this.backgroundColor,
    required this.label,
  });

  final String value;
  final String assetPath;
  final Color backgroundColor;
  final String label;
}

class _AvatarSlide extends StatelessWidget {
  const _AvatarSlide({required this.avatar, required this.selected, super.key});

  final _AvatarChoice avatar;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = _tagColors(context);

    return Semantics(
      button: true,
      selected: selected,
      label: avatar.label,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: selected ? 184 : 142,
          height: selected ? 184 : 142,
          decoration: BoxDecoration(
            color: avatar.backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? colors.brandPrimary : colors.borderDefault,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(selected ? 10 : 13),
            child: Image.asset(
              avatar.assetPath,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPositionDots extends StatelessWidget {
  const _AvatarPositionDots({
    required this.currentIndex,
    required this.itemCount,
  });

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = _tagColors(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < itemCount; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: index == currentIndex ? 18 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: index == currentIndex
                  ? colors.brandPrimary
                  : colors.borderDefault,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _LocalFirstStep extends StatelessWidget {
  const _LocalFirstStep({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Private by default',
      body:
          'Tag reads saved things with local models on this device. Choose how you want first setup to feel.',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: const ValueKey('local_models_start_sooner_button'),
            onPressed: state.isBusy
                ? null
                : context.read<OnboardingCubit>().chooseFastLocalSetup,
            icon: const Icon(Icons.bolt_outlined),
            label: Text(state.isBusy ? 'Saving' : 'Start sooner'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const ValueKey('local_models_best_quality_button'),
            onPressed: state.isBusy
                ? null
                : context.read<OnboardingCubit>().chooseBestQualityLocalSetup,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: const Text('Best quality'),
          ),
        ],
      ),
      children: [
        _InfoBand(
          icon: Icons.phonelink_lock_outlined,
          title: 'No login',
          body: 'No account, cloud sync, or remote AI fallback in the MVP.',
        ),
        const SizedBox(height: TagSpacing.s3),
        _InfoBand(
          icon: Icons.downloading_rounded,
          title: 'Local setup',
          body:
              'Start sooner downloads a smaller local card model. Best quality can take longer on first launch. You can change this later in Model setup.',
        ),
      ],
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      title: 'Notifications are optional.',
      body:
          'Only active Urgent Cards and Goal Cards can notify you. Suggestion Cards stay in the app.',
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            key: const ValueKey('enable_notifications_button'),
            onPressed: state.isBusy
                ? null
                : context.read<OnboardingCubit>().requestNotifications,
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(state.isBusy ? 'Saving' : 'Enable notifications'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            key: const ValueKey('skip_notifications_button'),
            onPressed: state.isBusy
                ? null
                : context.read<OnboardingCubit>().skipNotifications,
            child: const Text('Skip for now'),
          ),
        ],
      ),
      children: [
        _InfoBand(
          icon: Icons.notifications_none_rounded,
          title: 'Quiet by default',
          body: 'Skip this now and Tag will still open your local Today feed.',
        ),
      ],
    );
  }
}

class _ShareStep extends StatelessWidget {
  const _ShareStep({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final greeting = state.nickname.trim().isEmpty
        ? 'You are ready.'
        : 'Welcome, ${state.nickname.trim()}.';

    return _StepScaffold(
      title: greeting,
      body:
          'Try saving your first thing. When you take a screenshot, use iOS Share and choose Tag.',
      action: FilledButton.icon(
        key: const ValueKey('finish_onboarding_button'),
        onPressed: state.isBusy
            ? null
            : context.read<OnboardingCubit>().complete,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(state.isBusy ? 'Saving' : 'Go to Today'),
      ),
      children: const [
        _ShareRow(index: '1', text: 'Take a screenshot'),
        _ShareRow(index: '2', text: 'Tap Share'),
        _ShareRow(index: '3', text: 'Choose Tag'),
      ],
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({
    required this.title,
    required this.body,
    required this.action,
    this.children = const [],
  });

  final String title;
  final String body;
  final Widget action;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.displaySmall),
        const SizedBox(height: TagSpacing.s3),
        Text(
          body,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        if (children.isNotEmpty) ...[
          const SizedBox(height: TagSpacing.s6),
          ...children,
        ],
        const SizedBox(height: TagSpacing.s8),
        action,
      ],
    );
  }
}

class _IndexCardIllustration extends StatelessWidget {
  const _IndexCardIllustration();

  @override
  Widget build(BuildContext context) {
    final colors = _tagColors(context);

    return SizedBox(
      height: 104,
      child: Stack(
        children: [
          Positioned(
            left: 18,
            right: 18,
            top: 18,
            child: _IllustrationCard(
              color: colors.backgroundSubtle,
              borderColor: colors.borderDefault,
            ),
          ),
          Positioned(
            left: 6,
            right: 6,
            top: 8,
            child: _IllustrationCard(
              color: colors.surfaceElevated,
              borderColor: colors.borderDefault,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(TagRadii.card),
                border: Border.all(color: colors.borderDefault),
                boxShadow: [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(TagSpacing.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _MiniPill(color: colors.suggestionSoft, width: 76),
                        const SizedBox(width: TagSpacing.s2),
                        _MiniPill(color: colors.surfaceSunken, width: 52),
                      ],
                    ),
                    const SizedBox(height: TagSpacing.s3),
                    _MiniLine(color: colors.textPrimary, width: 164),
                    const SizedBox(height: TagSpacing.s2),
                    _MiniLine(color: colors.textSecondary, width: 220),
                    const SizedBox(height: TagSpacing.s3),
                    _MiniPill(color: colors.brandSoft, width: 118),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IllustrationCard extends StatelessWidget {
  const _IllustrationCard({required this.color, required this.borderColor});

  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(TagRadii.card),
        border: Border.all(color: borderColor),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 8,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(TagRadii.chip),
      ),
    );
  }
}

class _InfoBand extends StatelessWidget {
  const _InfoBand({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _tagColors(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(TagRadii.card),
        border: Border.all(color: colors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(TagSpacing.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(TagSpacing.s3),
                child: Icon(icon, size: 22, color: colors.brandSoftText),
              ),
            ),
            const SizedBox(width: TagSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: TagSpacing.s1),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.index, required this.text});

  final String index;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _tagColors(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: TagSpacing.s3),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceCard,
          borderRadius: BorderRadius.circular(TagRadii.compactCard),
          border: Border.all(color: colors.borderDefault),
        ),
        child: Padding(
          padding: const EdgeInsets.all(TagSpacing.s4),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colors.brandSoft,
                foregroundColor: colors.brandSoftText,
                child: Text(index, style: theme.textTheme.labelLarge),
              ),
              const SizedBox(width: TagSpacing.s3),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.furthestStep});

  final OnboardingStep step;
  final OnboardingStep furthestStep;

  @override
  Widget build(BuildContext context) {
    final colors = _tagColors(context);
    final currentIndex = OnboardingStep.values.indexOf(step);
    final furthestIndex = OnboardingStep.values.indexOf(furthestStep);

    return Row(
      children: [
        for (var index = 0; index < OnboardingStep.values.length; index++)
          Expanded(
            child: _StepPill(
              index: index,
              currentIndex: currentIndex,
              furthestIndex: furthestIndex,
              colors: colors,
              onTap: index <= furthestIndex
                  ? () => context.read<OnboardingCubit>().goToStep(
                      OnboardingStep.values[index],
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.index,
    required this.currentIndex,
    required this.furthestIndex,
    required this.colors,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final int furthestIndex;
  final TagThemeColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCurrent = index == currentIndex;
    final isReached = index <= furthestIndex;
    final step = OnboardingStep.values[index];
    final color = isReached ? colors.brandPrimary : colors.borderStrong;

    return Semantics(
      button: true,
      enabled: onTap != null,
      selected: isCurrent,
      label: 'Onboarding ${_stepLabel(step)}',
      child: GestureDetector(
        key: ValueKey('onboarding_step_${step.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: isCurrent ? 8 : 6,
              margin: EdgeInsets.only(
                right: index == OnboardingStep.values.length - 1
                    ? 0
                    : TagSpacing.s2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isReached ? 1 : 0.8),
                borderRadius: BorderRadius.circular(TagRadii.chip),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _stepLabel(OnboardingStep step) {
    return switch (step) {
      OnboardingStep.welcome => 'welcome',
      OnboardingStep.nickname => 'nickname',
      OnboardingStep.avatar => 'avatar',
      OnboardingStep.localFirst => 'local-first',
      OnboardingStep.notifications => 'notifications',
      OnboardingStep.share => 'share',
    };
  }
}
