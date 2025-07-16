import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
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
            _buildTemplatePreviewSection(),
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
                onTap: () => _showComingSoon(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

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

  Widget _buildTemplatePreviewSection() {
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

              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: UIStyles.spacingM),
                child: _buildTemplateCard(
                  templates[index]['emoji']!,
                  templates[index]['name']!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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

  void _startCardCreation(BuildContext context) {
    // 추후 템플릿 선택 화면으로 이동
    _showComingSoon(context);
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(AppEmojis.sticker),
            const SizedBox(width: UIStyles.spacingS),
            const Text('Coming Soon!'),
          ],
        ),
        content: const Text('이 기능은 곧 추가될 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

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
