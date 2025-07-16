import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';

/// 홈 화면 위젯
/// 앱의 메인 화면으로, 카드 생성 및 템플릿 탐색 기능 제공
class HomeScreen extends StatelessWidget {
  /// HomeScreen 생성자
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '카드톡 ',
              style: TextStyles.headingMedium.copyWith(
                color: ColorPalette.primaryPink,
              ),
            ),
            Text(AppEmojis.card, style: const TextStyle(fontSize: 24)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _resetOnboarding(context),
            tooltip: '온보딩 초기화 (테스트용)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIStyles.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 환영 메시지
            _buildWelcomeSection(),
            const SizedBox(height: UIStyles.spacingXL),

            // 빠른 시작 섹션
            _buildQuickStartSection(context),
            const SizedBox(height: UIStyles.spacingXL),

            // 템플릿 미리보기 섹션
            _buildTemplatePreviewSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startCardCreation(context),
        backgroundColor: ColorPalette.primaryPink,
        foregroundColor: Colors.white,
        icon: Text(AppEmojis.template, style: const TextStyle(fontSize: 20)),
        label: Text('카드 만들기', style: TextStyles.buttonMedium),
      ),
    );
  }

  /// 환영 섹션 위젯 생성
  /// 사용자 환영 메시지를 포함한 카드 형태의 UI 반환
  /// @return 환영 섹션 위젯
  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: UIStyles.cardPadding,
      decoration: BoxDecoration(
        color: ColorPalette.primaryLightPink,
        borderRadius: UIStyles.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AppEmojis.welcome, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: UIStyles.spacingS),
              Expanded(child: Text('환영합니다!', style: TextStyles.headingMedium)),
            ],
          ),
          const SizedBox(height: UIStyles.spacingS),
          Text(
            '감성 카드를 만들어 소중한 사람들과 마음을 나눠보세요.',
            style: TextStyles.bodyLarge.copyWith(
              color: ColorPalette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 빠른 시작 섹션 위젯 생성
  /// 템플릿 선택과 갤러리 접근을 위한 카드 UI 반환
  /// @param context 빌드 컨텍스트
  /// @return 빠른 시작 섹션 위젯
  Widget _buildQuickStartSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('빠른 시작', style: TextStyles.headingSmall),
        const SizedBox(height: UIStyles.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                emoji: AppEmojis.template,
                title: '템플릿 선택',
                subtitle: '다양한 템플릿 둘러보기',
                onTap: () => _startCardCreation(context),
              ),
            ),
            const SizedBox(width: UIStyles.spacingM),
            Expanded(
              child: _buildQuickActionCard(
                emoji: AppEmojis.photo,
                title: '갤러리',
                subtitle: '내 카드 모아보기',
                onTap: () => _openGallery(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 빠른 액션 카드 위젯 생성
  /// 빠른 시작 섹션에서 사용하는 액션 카드 UI 반환
  /// @param emoji 카드에 표시할 이모지
  /// @param title 카드 제목
  /// @param subtitle 카드 부제목
  /// @param onTap 탭 이벤트 핸들러
  /// @return 액션 카드 위젯
  Widget _buildQuickActionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: UIStyles.cardPadding,
        decoration: BoxDecoration(
          color: ColorPalette.cardBackground,
          borderRadius: UIStyles.cardRadius,
          boxShadow: UIStyles.cardShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: UIStyles.spacingS),
            Text(
              title,
              style: TextStyles.subtitleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIStyles.spacingXS),
            Text(
              subtitle,
              style: TextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 템플릿 미리보기 섹션 위젯 생성
  /// 인기 템플릿을 가로 스크롤 형태로 보여주는 UI 반환
  /// @param context 빌드 컨텍스트
  /// @return 템플릿 미리보기 섹션 위젯
  Widget _buildTemplatePreviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('인기 템플릿', style: TextStyles.headingSmall),
        const SizedBox(height: UIStyles.spacingM),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              final templates = [
                {'emoji': AppEmojis.love, 'name': '사랑'},
                {'emoji': AppEmojis.celebration, 'name': '축하'},
                {'emoji': AppEmojis.happy, 'name': '행복'},
                {'emoji': AppEmojis.gift, 'name': '선물'},
                {'emoji': AppEmojis.surprise, 'name': '놀람'},
              ];

              return GestureDetector(
                onTap: () => _startCardCreation(context),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: UIStyles.spacingM),
                  child: _buildTemplateCard(
                    templates[index]['emoji']!,
                    templates[index]['name']!,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 템플릿 카드 위젯 생성
  /// 템플릿 미리보기에서 사용하는 개별 템플릿 카드 UI 반환
  /// @param emoji 템플릿 이모지
  /// @param name 템플릿 이름
  /// @return 템플릿 카드 위젯
  Widget _buildTemplateCard(String emoji, String name) {
    return Container(
      padding: const EdgeInsets.all(UIStyles.spacingM),
      decoration: BoxDecoration(
        color: ColorPalette.secondaryLightMint,
        borderRadius: UIStyles.cardRadius,
        border: Border.all(color: ColorPalette.secondaryMint, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: UIStyles.spacingS),
          Text(name, style: TextStyles.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /// 카드 생성 시작
  /// 카드 생성 화면으로 이동하는 함수
  /// @param context 빌드 컨텍스트
  void _startCardCreation(BuildContext context) {
    // 템플릿 목록 화면으로 이동
    Navigator.of(context).pushNamed('/templates');
  }

  /// 갤러리 화면 열기
  /// 갤러리 화면으로 이동하는 함수
  /// @param context 빌드 컨텍스트
  void _openGallery(BuildContext context) {
    // 갤러리 화면으로 이동
    Navigator.of(context).pushNamed('/gallery');
  }

  /// 온보딩 초기화 (테스트용)
  /// 온보딩 상태를 초기화하고 앱을 재시작하는 효과를 내는 함수
  /// @param context 빌드 컨텍스트
  void _resetOnboarding(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(
      context,
      listen: false,
    );

    onboardingProvider.resetOnboarding();

    // 앱 재시작을 시뮬레이션하기 위해 새로운 화면으로 교체
    Navigator.of(context).pushReplacementNamed('/');
  }
}
