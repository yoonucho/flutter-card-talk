import '../utils/constants.dart';

/// 온보딩 페이지 데이터 모델
/// 앱 시작 시 사용자에게 보여줄 온보딩 화면의 각 페이지 정보를 담는 클래스
class OnboardingPage {
  /// 온보딩 페이지 제목
  final String title;

  /// 온보딩 페이지 설명 텍스트
  final String description;

  /// 온보딩 페이지에 표시할 이미지 경로
  final String imageAsset;

  /// 온보딩 페이지와 관련된 이모지
  final String emoji;

  /// 온보딩 페이지 생성자
  /// @param title 페이지 제목
  /// @param description 페이지 설명
  /// @param imageAsset 이미지 경로
  /// @param emoji 관련 이모지
  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.emoji,
  });
}

/// 온보딩 페이지 데이터 리스트
/// 앱에서 사용할 모든 온보딩 페이지 정보를 정의
/// 총 4개의 페이지로 구성: 환영, 템플릿 선택, 카드 만들기, 공유하기
final List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    title: '카드톡에 오신 것을 환영합니다! ${AppEmojis.welcome}',
    description: '감성 카드를 쉽게 만들어 소중한 사람들과 공유해보세요.',
    imageAsset: 'assets/images/onboarding_welcome.png',
    emoji: AppEmojis.welcome,
  ),
  OnboardingPage(
    title: '다양한 템플릿 선택 ${AppEmojis.template}',
    description: '취향에 맞는 다양한 템플릿을 골라보세요.',
    imageAsset: 'assets/images/onboarding_template.png',
    emoji: AppEmojis.template,
  ),
  OnboardingPage(
    title: '나만의 카드 만들기 ${AppEmojis.edit}',
    description: '텍스트와 이미지를 추가하여 나만의 카드를 만들어보세요.',
    imageAsset: 'assets/images/onboarding_edit.png',
    emoji: AppEmojis.edit,
  ),
  OnboardingPage(
    title: '소중한 사람과 공유하기 ${AppEmojis.share}',
    description: '완성된 카드를 소중한 사람들과 공유해보세요.',
    imageAsset: 'assets/images/onboarding_share.png',
    emoji: AppEmojis.share,
  ),
];
