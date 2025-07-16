import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import '../../models/onboarding_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatelessWidget {
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
