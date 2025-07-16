import 'package:flutter/material.dart';

/// 앱에서 사용하는 색상 팔레트
/// 앱 전체의 일관된 색상 테마를 위한 상수 정의
class ColorPalette {
  // 주요 색상 (Primary)
  /// 앱의 주요 핑크 색상
  static const Color primaryPink = Color(0xFFFF9AAC);

  /// 밝은 핑크 색상 (배경, 강조 효과 등에 사용)
  static const Color primaryLightPink = Color(0xFFFFCCD5);

  /// 어두운 핑크 색상 (강조, 그림자 등에 사용)
  static const Color primaryDarkPink = Color(0xFFE57B92);

  // 보조 색상 (Secondary)
  /// 민트 색상 (보조 색상)
  static const Color secondaryMint = Color(0xFFA8E6CF);

  /// 밝은 민트 색상 (배경, 강조 효과 등에 사용)
  static const Color secondaryLightMint = Color(0xFFDFFFF0);

  /// 노란색 계열 보조 색상
  static const Color secondaryYellow = Color(0xFFFFD3B6);

  /// 라벤더 색상 보조 색상
  static const Color secondaryLavender = Color(0xFFD4A5FF);

  // 강조 색상 (Accent)
  /// 코랄 색상 (강조 효과)
  static const Color accentCoral = Color(0xFFFF8B94);

  /// 하늘색 (강조 효과)
  static const Color accentSkyBlue = Color(0xFFA2D2FF);

  // 중립 색상 (Neutral)
  /// 주요 텍스트 색상
  static const Color textPrimary = Color(0xFF333333);

  /// 보조 텍스트 색상
  static const Color textSecondary = Color(0xFF666666);

  /// 앱 배경 색상
  static const Color background = Color(0xFFFFFFFF);

  /// 카드 배경 색상
  static const Color cardBackground = Color(0xFFFAFAFA);

  /// 구분선 색상
  static const Color divider = Color(0xFFEEEEEE);
}

/// 앱에서 사용하는 텍스트 스타일
/// 앱 전체의 일관된 텍스트 스타일을 위한 상수 정의
class TextStyles {
  // 제목 스타일
  /// 큰 제목 스타일 (앱 이름, 메인 헤더 등)
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ColorPalette.primaryPink,
  );

  /// 중간 크기 제목 스타일 (섹션 헤더 등)
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColorPalette.textPrimary,
  );

  /// 작은 제목 스타일 (소제목 등)
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textPrimary,
  );

  // 부제목 스타일
  /// 큰 부제목 스타일
  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ColorPalette.textSecondary,
  );

  /// 중간 크기 부제목 스타일
  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: ColorPalette.textSecondary,
  );

  // 본문 스타일
  /// 큰 본문 텍스트 스타일 (강조된 본문 등)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textPrimary,
  );

  /// 일반 본문 텍스트 스타일
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textPrimary,
  );

  /// 작은 본문 텍스트 스타일 (부가 정보 등)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textSecondary,
  );

  // 버튼 스타일
  /// 큰 버튼 텍스트 스타일
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// 일반 버튼 텍스트 스타일
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// 작은 버튼 텍스트 스타일
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 캡션 스타일
  /// 캡션 텍스트 스타일 (이미지 설명, 작은 정보 등)
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: ColorPalette.textSecondary,
  );
}

/// 앱에서 사용하는 이모지
/// 앱 전체에서 일관되게 사용할 이모지 모음
class AppEmojis {
  // 온보딩 관련 이모지
  /// 환영 이모지 (손 흔드는 모양)
  static const String welcome = "👋";

  /// 템플릿 이모지 (팔레트)
  static const String template = "🎨";

  /// 편집 이모지 (연필)
  static const String edit = "✏️";

  /// 공유 이모지 (로켓)
  static const String share = "🚀";

  /// 완료 이모지 (축하)
  static const String complete = "🎉";

  // 감정 표현 이모지
  /// 행복 이모지 (미소)
  static const String happy = "😊";

  /// 사랑 이모지 (하트)
  static const String love = "❤️";

  /// 놀람 이모지
  static const String surprise = "😲";

  /// 슬픔 이모지 (눈물)
  static const String sad = "😢";

  /// 축하 이모지 (케이크)
  static const String celebration = "🎂";

  // 카드 관련 이모지
  /// 카드 이모지 (편지)
  static const String card = "💌";

  /// 사진 이모지 (카메라)
  static const String photo = "📷";

  /// 텍스트 이모지 (말풍선)
  static const String text = "💬";

  /// 스티커 이모지 (별)
  static const String sticker = "🌟";

  /// 선물 이모지
  static const String gift = "🎁";
}

/// 앱에서 사용하는 UI 스타일
/// 앱 전체의 일관된 UI 요소 스타일을 위한 상수 정의
class UIStyles {
  // 버튼 스타일
  /// 버튼의 모서리 둥글기
  static final BorderRadius buttonRadius = BorderRadius.circular(20.0);

  // 카드 스타일
  /// 카드의 모서리 둥글기
  static final BorderRadius cardRadius = BorderRadius.circular(16.0);

  /// 카드의 그림자 효과
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 10.0,
      offset: const Offset(0, 2),
    ),
  ];

  /// 카드 내부 여백
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);

  // 입력 필드 스타일
  /// 입력 필드의 모서리 둥글기
  static final BorderRadius inputRadius = BorderRadius.circular(12.0);

  // 간격 및 여백
  /// 아주 작은 간격 (4dp)
  static const double spacingXS = 4.0;

  /// 작은 간격 (8dp)
  static const double spacingS = 8.0;

  /// 중간 간격 (16dp)
  static const double spacingM = 16.0;

  /// 큰 간격 (24dp)
  static const double spacingL = 24.0;

  /// 아주 큰 간격 (32dp)
  static const double spacingXL = 32.0;
}

/// 앱에서 사용하는 애니메이션
/// 앱 전체의 일관된 애니메이션 효과를 위한 상수 정의
class Animations {
  // 지속 시간
  /// 빠른 애니메이션 지속 시간 (200ms)
  static const Duration fastDuration = Duration(milliseconds: 200);

  /// 일반 애니메이션 지속 시간 (300ms)
  static const Duration normalDuration = Duration(milliseconds: 300);

  /// 느린 애니메이션 지속 시간 (500ms)
  static const Duration slowDuration = Duration(milliseconds: 500);

  // 애니메이션 곡선
  /// 기본 애니메이션 곡선 (부드러운 가속/감속)
  static const Curve defaultCurve = Curves.easeInOut;

  /// 통통 튀는 애니메이션 곡선
  static const Curve bouncyCurve = Curves.elasticOut;

  /// 부드러운 애니메이션 곡선 (빠르게 시작해서 천천히 끝남)
  static const Curve smoothCurve = Curves.fastOutSlowIn;
}
