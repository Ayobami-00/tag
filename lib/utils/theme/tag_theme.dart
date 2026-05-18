import 'package:flutter/material.dart';

class TagTheme {
  const TagTheme._();

  static ThemeData get lightTheme => _buildTheme(_TagPalette.light);

  static ThemeData get darkTheme => _buildTheme(_TagPalette.dark);

  static ThemeData _buildTheme(_TagPalette palette) {
    final colorScheme = ColorScheme(
      brightness: palette.brightness,
      primary: palette.brandPrimary,
      onPrimary: palette.brandPrimaryText,
      secondary: palette.goalActive,
      onSecondary: palette.brandPrimaryText,
      tertiary: palette.suggestion,
      onTertiary: palette.brandPrimaryText,
      error: palette.urgent,
      onError: palette.brandPrimaryText,
      surface: palette.surfaceCard,
      onSurface: palette.textPrimary,
    );

    final textTheme = TextTheme(
      displaySmall: TextStyle(
        color: palette.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.08,
      ),
      headlineMedium: TextStyle(
        color: palette.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
      titleLarge: TextStyle(
        color: palette.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
      titleMedium: TextStyle(
        color: palette.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      titleSmall: TextStyle(
        color: palette.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      bodyLarge: TextStyle(
        color: palette.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        color: palette.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        color: palette.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      labelSmall: TextStyle(
        color: palette.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.2,
      ),
    );

    final borderRadius = BorderRadius.circular(TagRadii.button);
    final borderSide = BorderSide(color: palette.borderDefault);

    return ThemeData(
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.backgroundDefault,
      textTheme: textTheme,
      useMaterial3: true,
      extensions: [palette.colors],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.backgroundDefault,
        foregroundColor: palette.textPrimary,
        centerTitle: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceCard,
        elevation: palette.brightness == Brightness.light ? 1 : 0,
        shadowColor: const Color(0x1A171A1F),
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TagRadii.card),
          side: borderSide,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brandPrimary,
          foregroundColor: palette.brandPrimaryText,
          disabledBackgroundColor: palette.surfaceSunken,
          disabledForegroundColor: palette.textTertiary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: palette.textPrimary,
          disabledForegroundColor: palette.textTertiary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: borderSide,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.textSecondary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: palette.textPrimary,
          minimumSize: const Size.square(44),
          shape: const CircleBorder(),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.brandPrimary,
        foregroundColor: palette.brandPrimaryText,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceSunken,
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TagRadii.input),
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TagRadii.input),
          borderSide: BorderSide(color: palette.brandPrimary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TagRadii.input),
          borderSide: borderSide,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceSunken,
        selectedColor: palette.brandSoft,
        disabledColor: palette.surfaceSunken,
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: palette.brandSoftText,
        ),
        side: borderSide,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TagRadii.chip),
        ),
      ),
      dividerTheme: DividerThemeData(color: palette.borderDefault, space: 1),
    );
  }
}

abstract final class TagSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
}

abstract final class TagRadii {
  static const double card = 20;
  static const double compactCard = 16;
  static const double button = 999;
  static const double chip = 999;
  static const double input = 18;
  static const double bottomSheet = 28;
  static const double sourcePreview = 12;
}

@immutable
class TagThemeColors extends ThemeExtension<TagThemeColors> {
  const TagThemeColors({
    required this.backgroundDefault,
    required this.backgroundSubtle,
    required this.surfaceCard,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderDefault,
    required this.borderStrong,
    required this.brandPrimary,
    required this.brandPrimaryText,
    required this.brandSoft,
    required this.brandSoftText,
    required this.urgent,
    required this.urgentSoft,
    required this.urgentText,
    required this.goalEarly,
    required this.goalEarlySoft,
    required this.goalEarlyText,
    required this.goalActive,
    required this.goalActiveSoft,
    required this.goalActiveText,
    required this.goalNearDone,
    required this.goalNearDoneSoft,
    required this.goalNearDoneText,
    required this.suggestion,
    required this.suggestionSoft,
    required this.suggestionText,
    required this.snoozed,
    required this.snoozedSoft,
    required this.snoozedText,
    required this.completed,
    required this.completedSoft,
    required this.completedText,
    required this.cancelled,
    required this.cancelledSoft,
    required this.cancelledText,
  });

  final Color backgroundDefault;
  final Color backgroundSubtle;
  final Color surfaceCard;
  final Color surfaceElevated;
  final Color surfaceSunken;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color borderDefault;
  final Color borderStrong;
  final Color brandPrimary;
  final Color brandPrimaryText;
  final Color brandSoft;
  final Color brandSoftText;
  final Color urgent;
  final Color urgentSoft;
  final Color urgentText;
  final Color goalEarly;
  final Color goalEarlySoft;
  final Color goalEarlyText;
  final Color goalActive;
  final Color goalActiveSoft;
  final Color goalActiveText;
  final Color goalNearDone;
  final Color goalNearDoneSoft;
  final Color goalNearDoneText;
  final Color suggestion;
  final Color suggestionSoft;
  final Color suggestionText;
  final Color snoozed;
  final Color snoozedSoft;
  final Color snoozedText;
  final Color completed;
  final Color completedSoft;
  final Color completedText;
  final Color cancelled;
  final Color cancelledSoft;
  final Color cancelledText;

  @override
  TagThemeColors copyWith({
    Color? backgroundDefault,
    Color? backgroundSubtle,
    Color? surfaceCard,
    Color? surfaceElevated,
    Color? surfaceSunken,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? borderDefault,
    Color? borderStrong,
    Color? brandPrimary,
    Color? brandPrimaryText,
    Color? brandSoft,
    Color? brandSoftText,
    Color? urgent,
    Color? urgentSoft,
    Color? urgentText,
    Color? goalEarly,
    Color? goalEarlySoft,
    Color? goalEarlyText,
    Color? goalActive,
    Color? goalActiveSoft,
    Color? goalActiveText,
    Color? goalNearDone,
    Color? goalNearDoneSoft,
    Color? goalNearDoneText,
    Color? suggestion,
    Color? suggestionSoft,
    Color? suggestionText,
    Color? snoozed,
    Color? snoozedSoft,
    Color? snoozedText,
    Color? completed,
    Color? completedSoft,
    Color? completedText,
    Color? cancelled,
    Color? cancelledSoft,
    Color? cancelledText,
  }) {
    return TagThemeColors(
      backgroundDefault: backgroundDefault ?? this.backgroundDefault,
      backgroundSubtle: backgroundSubtle ?? this.backgroundSubtle,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryText: brandPrimaryText ?? this.brandPrimaryText,
      brandSoft: brandSoft ?? this.brandSoft,
      brandSoftText: brandSoftText ?? this.brandSoftText,
      urgent: urgent ?? this.urgent,
      urgentSoft: urgentSoft ?? this.urgentSoft,
      urgentText: urgentText ?? this.urgentText,
      goalEarly: goalEarly ?? this.goalEarly,
      goalEarlySoft: goalEarlySoft ?? this.goalEarlySoft,
      goalEarlyText: goalEarlyText ?? this.goalEarlyText,
      goalActive: goalActive ?? this.goalActive,
      goalActiveSoft: goalActiveSoft ?? this.goalActiveSoft,
      goalActiveText: goalActiveText ?? this.goalActiveText,
      goalNearDone: goalNearDone ?? this.goalNearDone,
      goalNearDoneSoft: goalNearDoneSoft ?? this.goalNearDoneSoft,
      goalNearDoneText: goalNearDoneText ?? this.goalNearDoneText,
      suggestion: suggestion ?? this.suggestion,
      suggestionSoft: suggestionSoft ?? this.suggestionSoft,
      suggestionText: suggestionText ?? this.suggestionText,
      snoozed: snoozed ?? this.snoozed,
      snoozedSoft: snoozedSoft ?? this.snoozedSoft,
      snoozedText: snoozedText ?? this.snoozedText,
      completed: completed ?? this.completed,
      completedSoft: completedSoft ?? this.completedSoft,
      completedText: completedText ?? this.completedText,
      cancelled: cancelled ?? this.cancelled,
      cancelledSoft: cancelledSoft ?? this.cancelledSoft,
      cancelledText: cancelledText ?? this.cancelledText,
    );
  }

  @override
  TagThemeColors lerp(ThemeExtension<TagThemeColors>? other, double t) {
    if (other is! TagThemeColors) {
      return this;
    }

    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;

    return TagThemeColors(
      backgroundDefault: lerpColor(backgroundDefault, other.backgroundDefault),
      backgroundSubtle: lerpColor(backgroundSubtle, other.backgroundSubtle),
      surfaceCard: lerpColor(surfaceCard, other.surfaceCard),
      surfaceElevated: lerpColor(surfaceElevated, other.surfaceElevated),
      surfaceSunken: lerpColor(surfaceSunken, other.surfaceSunken),
      textPrimary: lerpColor(textPrimary, other.textPrimary),
      textSecondary: lerpColor(textSecondary, other.textSecondary),
      textTertiary: lerpColor(textTertiary, other.textTertiary),
      borderDefault: lerpColor(borderDefault, other.borderDefault),
      borderStrong: lerpColor(borderStrong, other.borderStrong),
      brandPrimary: lerpColor(brandPrimary, other.brandPrimary),
      brandPrimaryText: lerpColor(brandPrimaryText, other.brandPrimaryText),
      brandSoft: lerpColor(brandSoft, other.brandSoft),
      brandSoftText: lerpColor(brandSoftText, other.brandSoftText),
      urgent: lerpColor(urgent, other.urgent),
      urgentSoft: lerpColor(urgentSoft, other.urgentSoft),
      urgentText: lerpColor(urgentText, other.urgentText),
      goalEarly: lerpColor(goalEarly, other.goalEarly),
      goalEarlySoft: lerpColor(goalEarlySoft, other.goalEarlySoft),
      goalEarlyText: lerpColor(goalEarlyText, other.goalEarlyText),
      goalActive: lerpColor(goalActive, other.goalActive),
      goalActiveSoft: lerpColor(goalActiveSoft, other.goalActiveSoft),
      goalActiveText: lerpColor(goalActiveText, other.goalActiveText),
      goalNearDone: lerpColor(goalNearDone, other.goalNearDone),
      goalNearDoneSoft: lerpColor(goalNearDoneSoft, other.goalNearDoneSoft),
      goalNearDoneText: lerpColor(goalNearDoneText, other.goalNearDoneText),
      suggestion: lerpColor(suggestion, other.suggestion),
      suggestionSoft: lerpColor(suggestionSoft, other.suggestionSoft),
      suggestionText: lerpColor(suggestionText, other.suggestionText),
      snoozed: lerpColor(snoozed, other.snoozed),
      snoozedSoft: lerpColor(snoozedSoft, other.snoozedSoft),
      snoozedText: lerpColor(snoozedText, other.snoozedText),
      completed: lerpColor(completed, other.completed),
      completedSoft: lerpColor(completedSoft, other.completedSoft),
      completedText: lerpColor(completedText, other.completedText),
      cancelled: lerpColor(cancelled, other.cancelled),
      cancelledSoft: lerpColor(cancelledSoft, other.cancelledSoft),
      cancelledText: lerpColor(cancelledText, other.cancelledText),
    );
  }
}

class _TagPalette {
  const _TagPalette({required this.brightness, required this.colors});

  final Brightness brightness;
  final TagThemeColors colors;

  Color get backgroundDefault => colors.backgroundDefault;
  Color get surfaceCard => colors.surfaceCard;
  Color get surfaceSunken => colors.surfaceSunken;
  Color get textPrimary => colors.textPrimary;
  Color get textSecondary => colors.textSecondary;
  Color get textTertiary => colors.textTertiary;
  Color get borderDefault => colors.borderDefault;
  Color get brandPrimary => colors.brandPrimary;
  Color get brandPrimaryText => colors.brandPrimaryText;
  Color get brandSoft => colors.brandSoft;
  Color get brandSoftText => colors.brandSoftText;
  Color get urgent => colors.urgent;
  Color get goalActive => colors.goalActive;
  Color get suggestion => colors.suggestion;

  static const light = _TagPalette(
    brightness: Brightness.light,
    colors: TagThemeColors(
      backgroundDefault: Color(0xFFF8F7F2),
      backgroundSubtle: Color(0xFFF3F1EA),
      surfaceCard: Color(0xFFFFFFFF),
      surfaceElevated: Color(0xFFFFFEFB),
      surfaceSunken: Color(0xFFEFEEE8),
      textPrimary: Color(0xFF171A1F),
      textSecondary: Color(0xFF5F6673),
      textTertiary: Color(0xFF8A919E),
      borderDefault: Color(0xFFE7E2DA),
      borderStrong: Color(0xFFD6D0C7),
      brandPrimary: Color(0xFF3154D4),
      brandPrimaryText: Color(0xFFFFFFFF),
      brandSoft: Color(0xFFE8EDFF),
      brandSoftText: Color(0xFF253EA7),
      urgent: Color(0xFFD92D20),
      urgentSoft: Color(0xFFFEE4E2),
      urgentText: Color(0xFFB42318),
      goalEarly: Color(0xFF2563EB),
      goalEarlySoft: Color(0xFFDBEAFE),
      goalEarlyText: Color(0xFF1D4ED8),
      goalActive: Color(0xFF0F766E),
      goalActiveSoft: Color(0xFFDDF7F1),
      goalActiveText: Color(0xFF0B6358),
      goalNearDone: Color(0xFF166534),
      goalNearDoneSoft: Color(0xFFDCFCE7),
      goalNearDoneText: Color(0xFF166534),
      suggestion: Color(0xFF7C3AED),
      suggestionSoft: Color(0xFFEDE9FE),
      suggestionText: Color(0xFF5B21B6),
      snoozed: Color(0xFFB45309),
      snoozedSoft: Color(0xFFFEF3C7),
      snoozedText: Color(0xFF92400E),
      completed: Color(0xFF4B5563),
      completedSoft: Color(0xFFF3F4F6),
      completedText: Color(0xFF374151),
      cancelled: Color(0xFF57534E),
      cancelledSoft: Color(0xFFF5F5F4),
      cancelledText: Color(0xFF44403C),
    ),
  );

  static const dark = _TagPalette(
    brightness: Brightness.dark,
    colors: TagThemeColors(
      backgroundDefault: Color(0xFF0F1115),
      backgroundSubtle: Color(0xFF141720),
      surfaceCard: Color(0xFF171A21),
      surfaceElevated: Color(0xFF1E222B),
      surfaceSunken: Color(0xFF11141B),
      textPrimary: Color(0xFFF4F6FA),
      textSecondary: Color(0xFFB5BDCB),
      textTertiary: Color(0xFF8F98A8),
      borderDefault: Color(0xFF2A303B),
      borderStrong: Color(0xFF3A4250),
      brandPrimary: Color(0xFF8EA2FF),
      brandPrimaryText: Color(0xFF10131A),
      brandSoft: Color(0xFF202A5A),
      brandSoftText: Color(0xFFD9E0FF),
      urgent: Color(0xFFFFB4AB),
      urgentSoft: Color(0xFF3A1514),
      urgentText: Color(0xFFFFB4AB),
      goalEarly: Color(0xFFB8CCFF),
      goalEarlySoft: Color(0xFF142C57),
      goalEarlyText: Color(0xFFB8CCFF),
      goalActive: Color(0xFF84E6D4),
      goalActiveSoft: Color(0xFF0B2F2A),
      goalActiveText: Color(0xFF84E6D4),
      goalNearDone: Color(0xFFA7F3D0),
      goalNearDoneSoft: Color(0xFF123524),
      goalNearDoneText: Color(0xFFA7F3D0),
      suggestion: Color(0xFFD5C3FF),
      suggestionSoft: Color(0xFF29184A),
      suggestionText: Color(0xFFD5C3FF),
      snoozed: Color(0xFFFCD34D),
      snoozedSoft: Color(0xFF3A2A0A),
      snoozedText: Color(0xFFFCD34D),
      completed: Color(0xFFA8AFBD),
      completedSoft: Color(0xFF232832),
      completedText: Color(0xFFA8AFBD),
      cancelled: Color(0xFFA8A29E),
      cancelledSoft: Color(0xFF292524),
      cancelledText: Color(0xFFD6D3D1),
    ),
  );
}
