import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceStrong,
    required this.surfaceSoft,
    required this.textPrimary,
    required this.textMuted,
    required this.stroke,
    required this.accent,
    required this.secondaryAccent,
    required this.success,
    required this.successAccent,
    required this.warning,
    required this.danger,
    required this.heroStart,
    required this.heroEnd,
    required this.heroHighlight,
    required this.glow,
    required this.starColor,
    required this.bottomGlow,
    required this.cardShadow,
  });

  final Color background;
  final Color backgroundSecondary;
  final Color surface;
  final Color surfaceStrong;
  final Color surfaceSoft;
  final Color textPrimary;
  final Color textMuted;
  final Color stroke;
  final Color accent;
  final Color secondaryAccent;
  final Color success;
  final Color successAccent;
  final Color warning;
  final Color danger;
  final Color heroStart;
  final Color heroEnd;
  final Color heroHighlight;
  final Color glow;
  final Color starColor;
  final Color bottomGlow;
  final Color cardShadow;

  static const AppThemeColors dark = AppThemeColors(
    background: Color(0xFF08142E),
    backgroundSecondary: Color(0xFF102B54),
    surface: Color(0xFF111C3A),
    surfaceStrong: Color(0xFF16244A),
    surfaceSoft: Color(0xFF1C2D58),
    textPrimary: Color(0xFFF8FBFF),
    textMuted: Color(0xFF97A7C6),
    stroke: Color(0x2EFFFFFF),
    accent: Color(0xFF4B8DFF),
    secondaryAccent: Color(0xFF74D4FF),
    success: Color(0xFF40D7AA),
    successAccent: Color(0xFF047755),
    warning: Color(0xFFFFD166),
    danger: Color(0xFFFF6F91),
    heroStart: Color(0xFF101B44),
    heroEnd: Color(0xFF172A63),
    // heroHighlight: Color(0xFF59A8FF),
    heroHighlight: Color(0xFF0758B2),
    glow: Color(0x663D8BFF),
    starColor: Color(0xFFE8F4FF),
    bottomGlow: Color(0xFF2A62FF),
    cardShadow: Color(0x55050B19),
  );

  static const AppThemeColors light = AppThemeColors(
    background: Color(0xFFF2F6FF),
    backgroundSecondary: Color(0xFFDCE8FF),
    surface: Color(0xFFFFFFFF),
    surfaceStrong: Color(0xFFF6F9FF),
    surfaceSoft: Color(0xFFEAF1FF),
    textPrimary: Color(0xFF14213D),
    textMuted: Color(0xFF6D7B99),
    stroke: Color(0x14304B7A),
    accent: Color(0xFF3677FF),
    secondaryAccent: Color(0xFF6EC9FF),
    success: Color(0xFF20B989),
    successAccent: Color(0xFF20B989),
    warning: Color(0xFFF5B94D),
    danger: Color(0xFFF2617A),
    heroStart: Color(0xFFF6FAFF),
    heroEnd: Color(0xFFE4EEFF),
    heroHighlight: Color(0xFF4F8FFF),
    glow: Color(0x333677FF),
    starColor: Color(0x73FFFFFF),
    bottomGlow: Color(0xFF7FA9FF),
    cardShadow: Color(0x1A7092C3),
  );

  bool get isDark => background.computeLuminance() < 0.2;

  LinearGradient get pageGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [background, backgroundSecondary],
      );

  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [heroStart, heroEnd, heroHighlight],
      );
  LinearGradient get tabGradiant => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bottomGlow, bottomGlow, bottomGlow],
  );


  LinearGradient statusGradient(bool connected) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: connected
            ? [success.withOpacity(0.95), secondaryAccent.withOpacity(0.92)]
            : [heroStart, heroEnd],
      );

  BoxDecoration glassDecoration({double radius = 28}) {
    return BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.82),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: stroke),
      boxShadow: [
        BoxShadow(
          color: cardShadow,
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ],
    );
  }

  Color get panelFill => isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.92);
  Color get buttonFill => isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.96);
  Color get chipFill => isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFF2F6FF);
  Color get softIconFill => isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEFF4FF);
  Color get logFill => isDark ? Colors.black.withOpacity(0.18) : const Color(0xFFF8FBFF);
  Color get locationSheet => isDark ? const Color(0xFF1A2446) : const Color(0xFFFFFFFF);
  Color get worldMapTint => isDark ? Colors.white.withOpacity(0.05) : accent.withOpacity(0.08);
  Color get meterTrack => isDark ? Colors.white.withOpacity(0.10) : const Color(0xFFD8E5FF);

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? backgroundSecondary,
    Color? surface,
    Color? surfaceStrong,
    Color? surfaceSoft,
    Color? textPrimary,
    Color? textMuted,
    Color? stroke,
    Color? accent,
    Color? secondaryAccent,
    Color? success,
    Color? successAccent,
    Color? warning,
    Color? danger,
    Color? heroStart,
    Color? heroEnd,
    Color? heroHighlight,
    Color? glow,
    Color? starColor,
    Color? bottomGlow,
    Color? cardShadow,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surface: surface ?? this.surface,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      surfaceSoft: surfaceSoft ?? this.surfaceSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      stroke: stroke ?? this.stroke,
      accent: accent ?? this.accent,
      secondaryAccent: secondaryAccent ?? this.secondaryAccent,
      success: success ?? this.success,
      successAccent: successAccent ?? this.successAccent,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      heroHighlight: heroHighlight ?? this.heroHighlight,
      glow: glow ?? this.glow,
      starColor: starColor ?? this.starColor,
      bottomGlow: bottomGlow ?? this.bottomGlow,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  ThemeExtension<AppThemeColors> lerp(
    covariant ThemeExtension<AppThemeColors>? other,
    double t,
  ) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      surfaceSoft: Color.lerp(surfaceSoft, other.surfaceSoft, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      secondaryAccent: Color.lerp(secondaryAccent, other.secondaryAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      successAccent: Color.lerp(successAccent, other.successAccent, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      heroHighlight: Color.lerp(heroHighlight, other.heroHighlight, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      starColor: Color.lerp(starColor, other.starColor, t)!,
      bottomGlow: Color.lerp(bottomGlow, other.bottomGlow, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.dark;
}
