import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tag/utils/index.dart';

enum TopSignalTone { neutral, success, urgent, snoozed, suggestion, muted }

void showTopSignalBanner(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_rounded,
  TopSignalTone tone = TopSignalTone.neutral,
  Duration duration = const Duration(milliseconds: 2600),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    return;
  }

  _activeTopSignalEntry?.remove();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _TopSignalBannerOverlay(
      message: message,
      icon: icon,
      tone: tone,
      duration: duration,
      onDismissed: () {
        if (_activeTopSignalEntry == entry) {
          _activeTopSignalEntry = null;
        }
        if (entry.mounted) {
          entry.remove();
        }
      },
    ),
  );

  _activeTopSignalEntry = entry;
  overlay.insert(entry);
}

OverlayEntry? _activeTopSignalEntry;

class _TopSignalBannerOverlay extends StatefulWidget {
  const _TopSignalBannerOverlay({
    required this.message,
    required this.icon,
    required this.tone,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final IconData icon;
  final TopSignalTone tone;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopSignalBannerOverlay> createState() =>
      _TopSignalBannerOverlayState();
}

class _TopSignalBannerOverlayState extends State<_TopSignalBannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  Timer? _dismissTimer;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _controller.forward();
    _dismissTimer = Timer(widget.duration, _close);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    if (_isClosing) {
      return;
    }
    _isClosing = true;
    _dismissTimer?.cancel();

    if (mounted) {
      await _controller.reverse();
    }
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<TagThemeColors>()!;
    final brightness = Theme.of(context).brightness;
    final toneColors = _ToneColors.forTone(colors, widget.tone);
    final foreground = brightness == Brightness.light
        ? colors.surfaceElevated
        : colors.textPrimary;
    final background = brightness == Brightness.light
        ? colors.textPrimary
        : colors.surfaceElevated;
    final borderColor = brightness == Brightness.light
        ? colors.textPrimary.withValues(alpha: 0.18)
        : colors.borderStrong;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) {
          final value = _curve.value;
          final topInset = MediaQuery.paddingOf(context).top;
          final hiddenOffset = -(topInset + 84);
          final textOpacity = ((value - 0.16) / 0.84).clamp(0.0, 1.0);

          return Transform.translate(
            offset: Offset(0, lerpDouble(hiddenOffset, 0, value)!),
            child: Opacity(
              opacity: value,
              child: Semantics(
                liveRegion: true,
                label: widget.message,
                child: GestureDetector(
                  onTap: _close,
                  behavior: HitTestBehavior.opaque,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: colors.textPrimary.withValues(
                              alpha: brightness == Brightness.light
                                  ? 0.18
                                  : 0.40,
                            ),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          TagSpacing.s4,
                          topInset + TagSpacing.s2,
                          TagSpacing.s4,
                          TagSpacing.s3,
                        ),
                        child: Row(
                          children: [
                            _SignalIcon(icon: widget.icon, colors: toneColors),
                            Expanded(
                              child: Opacity(
                                opacity: textOpacity,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: TagSpacing.s3,
                                  ),
                                  child: Text(
                                    widget.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: foreground,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.icon, required this.colors});

  final IconData icon;
  final _ToneColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.soft, shape: BoxShape.circle),
      child: SizedBox.square(
        dimension: 36,
        child: Icon(icon, size: 20, color: colors.accent),
      ),
    );
  }
}

class _ToneColors {
  const _ToneColors({required this.accent, required this.soft});

  final Color accent;
  final Color soft;

  static _ToneColors forTone(TagThemeColors colors, TopSignalTone tone) {
    return switch (tone) {
      TopSignalTone.success => _ToneColors(
        accent: colors.completedText,
        soft: colors.completedSoft,
      ),
      TopSignalTone.urgent => _ToneColors(
        accent: colors.urgentText,
        soft: colors.urgentSoft,
      ),
      TopSignalTone.snoozed => _ToneColors(
        accent: colors.snoozedText,
        soft: colors.snoozedSoft,
      ),
      TopSignalTone.suggestion => _ToneColors(
        accent: colors.suggestionText,
        soft: colors.suggestionSoft,
      ),
      TopSignalTone.muted => _ToneColors(
        accent: colors.cancelledText,
        soft: colors.cancelledSoft,
      ),
      TopSignalTone.neutral => _ToneColors(
        accent: colors.brandSoftText,
        soft: colors.brandSoft,
      ),
    };
  }
}
