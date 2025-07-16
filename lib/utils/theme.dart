import 'package:flutter/material.dart';
import 'constants.dart';

/// 앱의 기본 테마를 반환하는 함수
ThemeData getAppTheme() {
  return ThemeData(
    // 기본 색상 설정
    primaryColor: ColorPalette.primaryPink,
    scaffoldBackgroundColor: ColorPalette.background,
    colorScheme: ColorScheme.light(
      primary: ColorPalette.primaryPink,
      secondary: ColorPalette.secondaryMint,
      onPrimary: Colors.white,
      onSecondary: ColorPalette.textPrimary,
    ),

    // AppBar 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPalette.primaryLightPink,
      foregroundColor: ColorPalette.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyles.headingMedium,
    ),

    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.primaryPink,
        foregroundColor: Colors.white,
        textStyle: TextStyles.buttonMedium,
        shape: RoundedRectangleBorder(borderRadius: UIStyles.buttonRadius),
        padding: const EdgeInsets.symmetric(
          horizontal: UIStyles.spacingL,
          vertical: UIStyles.spacingM,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColorPalette.primaryPink,
        textStyle: TextStyles.buttonMedium,
        side: const BorderSide(color: ColorPalette.primaryPink),
        shape: RoundedRectangleBorder(borderRadius: UIStyles.buttonRadius),
        padding: const EdgeInsets.symmetric(
          horizontal: UIStyles.spacingL,
          vertical: UIStyles.spacingM,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColorPalette.primaryPink,
        textStyle: TextStyles.buttonMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: UIStyles.spacingM,
          vertical: UIStyles.spacingS,
        ),
      ),
    ),

    // 카드 테마
    cardTheme: const CardThemeData(
      color: ColorPalette.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      margin: EdgeInsets.all(16.0),
    ),

    // 텍스트 테마
    textTheme: const TextTheme(
      headlineLarge: TextStyles.headingLarge,
      headlineMedium: TextStyles.headingMedium,
      headlineSmall: TextStyles.headingSmall,
      titleLarge: TextStyles.subtitleLarge,
      titleMedium: TextStyles.subtitleMedium,
      bodyLarge: TextStyles.bodyLarge,
      bodyMedium: TextStyles.bodyMedium,
      bodySmall: TextStyles.bodySmall,
      labelLarge: TextStyles.buttonLarge,
      labelMedium: TextStyles.buttonMedium,
      labelSmall: TextStyles.buttonSmall,
    ),

    // 입력 필드 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UIStyles.spacingM,
        vertical: UIStyles.spacingM,
      ),
      border: OutlineInputBorder(
        borderRadius: UIStyles.inputRadius,
        borderSide: const BorderSide(color: ColorPalette.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: UIStyles.inputRadius,
        borderSide: const BorderSide(color: ColorPalette.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: UIStyles.inputRadius,
        borderSide: const BorderSide(color: ColorPalette.primaryPink),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: UIStyles.inputRadius,
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),
  );
}
