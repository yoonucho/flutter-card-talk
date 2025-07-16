import 'package:flutter/material.dart';

/// 앱에서 사용하는 색상 팔레트
class ColorPalette {
  // 주요 색상 (Primary)
  static const Color primaryPink = Color(0xFFFF9AAC);
  static const Color primaryLightPink = Color(0xFFFFCCD5);
  static const Color primaryDarkPink = Color(0xFFE57B92);

  // 보조 색상 (Secondary)
  static const Color secondaryMint = Color(0xFFA8E6CF);
  static const Color secondaryLightMint = Color(0xFFDFFFF0);
  static const Color secondaryYellow = Color(0xFFFFD3B6);
  static const Color secondaryLavender = Color(0xFFD4A5FF);

  // 강조 색상 (Accent)
  static const Color accentCoral = Color(0xFFFF8B94);
  static const Color accentSkyBlue = Color(0xFFA2D2FF);

  // 중립 색상 (Neutral)
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color divider = Color(0xFFEEEEEE);
}

/// 앱에서 사용하는 텍스트 스타일
class TextStyles {
  // 제목 스타일
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ColorPalette.primaryPink,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColorPalette.textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
  );

  // 부제목 스타일
  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textSecondary,
  );

  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textSecondary,
  );

  // 본문 스타일
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textSecondary,
  );

  // 버튼 스타일
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 캡션 스타일
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textSecondary,
  );
}

/// 앱에서 사용하는 이모지
class AppEmojis {
  // 온보딩 관련 이모지
  static const String welcome = "👋";
  static const String template = "🎨";
  static const String edit = "✏️";
  static const String share = "🚀";
  static const String complete = "🎉";

  // 감정 표현 이모지
  static const String happy = "😊";
  static const String love = "❤️";
  static const String surprise = "😲";
  static const String sad = "😢";
  static const String celebration = "🎂";

  // 카드 관련 이모지
  static const String card = "💌";
  static const String photo = "📷";
  static const String text = "💬";
  static const String sticker = "🌟";
  static const String gift = "🎁";
}

/// 앱에서 사용하는 UI 스타일
class UIStyles {
  // 버튼 스타일
  static final BorderRadius buttonRadius = BorderRadius.circular(20.0);

  // 카드 스타일
  static final BorderRadius cardRadius = BorderRadius.circular(16.0);
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 10.0,
      offset: const Offset(0, 2),
    ),
  ];
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  // 입력 필드 스타일
  static final BorderRadius inputRadius = BorderRadius.circular(12.0);

  // 간격 및 여백
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
}

/// 앱에서 사용하는 애니메이션
class Animations {
  // 지속 시간
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);

  // 애니메이션 곡선
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bouncyCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.fastOutSlowIn;
}
