import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import '../../models/onboarding_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';

/// 온보딩 화면 위젯
/// 앱 최초 실행 시 사용자에게 앱의 주요 기능을 소개하는 화면
class OnboardingScreen extends StatelessWidget {
  /// OnboardingScreen 생성자
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: _buildPages(),
        onDone: () => _onIntroEnd(context),
        onSkip: () => _onIntroEnd(context),
        showSkipButton: true,
        skipOrBackFlex: 0,
        nextFlex: 0,
        showBackButton: false,
        back: const Icon(Icons.arrow_back),
        skip: Text(
          '건너뛰기',
          style: TextStyles.buttonMedium.copyWith(
            color: ColorPalette.textSecondary,
          ),
        ),
        next: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIStyles.spacingL,
            vertical: UIStyles.spacingS,
          ),
          decoration: BoxDecoration(
            color: ColorPalette.primaryPink,
            borderRadius: UIStyles.buttonRadius,
          ),
          child: Text('다음', style: TextStyles.buttonMedium),
        ),
        done: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIStyles.spacingL,
            vertical: UIStyles.spacingS,
          ),
          decoration: BoxDecoration(
            color: ColorPalette.primaryPink,
            borderRadius: UIStyles.buttonRadius,
          ),
          child: Text('시작하기', style: TextStyles.buttonMedium),
        ),
        curve: Animations.defaultCurve,
        controlsMargin: const EdgeInsets.all(UIStyles.spacingM),
        controlsPadding: const EdgeInsets.fromLTRB(
          UIStyles.spacingS,
          0.0,
          UIStyles.spacingS,
          UIStyles.spacingS,
        ),
        dotsDecorator: DotsDecorator(
          size: const Size(10.0, 10.0),
          color: ColorPalette.divider,
          activeSize: const Size(22.0, 10.0),
          activeColor: ColorPalette.primaryPink,
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIStyles.spacingS),
          ),
        ),
        dotsContainerDecorator: const ShapeDecoration(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
      ),
    );
  }

  /// 온보딩 페이지 목록 생성
  /// 온보딩 모델에서 정의된 페이지 데이터를 기반으로 PageViewModel 목록 생성
  /// @return 온보딩 페이지 목록
  List<PageViewModel> _buildPages() {
    return onboardingPages.map((page) {
      return PageViewModel(
        title: page.title,
        body: page.description,
        image: _buildImage(page),
        decoration: PageDecoration(
          titleTextStyle: TextStyles.headingMedium.copyWith(
            color: ColorPalette.primaryPink,
          ),
          bodyTextStyle: TextStyles.bodyLarge.copyWith(
            color: ColorPalette.textSecondary,
          ),
          bodyPadding: const EdgeInsets.fromLTRB(
            UIStyles.spacingM,
            0.0,
            UIStyles.spacingM,
            UIStyles.spacingM,
          ),
          pageColor: ColorPalette.background,
          imagePadding: const EdgeInsets.only(top: UIStyles.spacingXL),
        ),
      );
    }).toList();
  }

  /// 온보딩 페이지 이미지 위젯 생성
  /// 각 온보딩 페이지에 표시될 이미지 또는 이모지 위젯 생성
  /// @param page 온보딩 페이지 데이터
  /// @return 이미지 위젯
  Widget _buildImage(OnboardingPage page) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(UIStyles.spacingXL),
            decoration: BoxDecoration(
              color: ColorPalette.primaryLightPink,
              borderRadius: BorderRadius.circular(100),
              boxShadow: UIStyles.cardShadow,
            ),
            child: Text(page.emoji, style: const TextStyle(fontSize: 80)),
          ),
          const SizedBox(height: UIStyles.spacingL),
          // 실제 이미지가 있다면 아래 코드를 사용
          // Image.asset(
          //   page.imageAsset,
          //   height: 200,
          //   fit: BoxFit.contain,
          // ),
        ],
      ),
    );
  }

  /// 온보딩 완료 처리
  /// 온보딩 완료 상태를 저장하고 홈 화면으로 이동
  /// @param context 빌드 컨텍스트
  void _onIntroEnd(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );

    // 온보딩 완료 처리
    onboardingProvider.completeOnboarding();

    // 홈 화면으로 이동
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }
}
