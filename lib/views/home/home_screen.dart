import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/template_provider.dart';
import '../../models/template_model.dart';
import '../../utils/constants.dart';
import '../../views/template/template_edit_screen.dart';

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
    // 카테고리 목록 정의
    final categories = [
      {
        'category': TemplateCategory.love,
        'emoji': AppEmojis.love,
        'name': '사랑',
      },
      {
        'category': TemplateCategory.celebration,
        'emoji': AppEmojis.celebration,
        'name': '축하',
      },
      {
        'category': TemplateCategory.birthday,
        'emoji': AppEmojis.celebration,
        'name': '생일',
      },
      {
        'category': TemplateCategory.comfort,
        'emoji': AppEmojis.happy,
        'name': '위로',
      },
      {
        'category': TemplateCategory.friendship,
        'emoji': AppEmojis.card,
        'name': '우정',
      },
      {
        'category': TemplateCategory.gratitude,
        'emoji': AppEmojis.gift,
        'name': '감사',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('인기 템플릿', style: TextStyles.headingSmall),
        const SizedBox(height: UIStyles.spacingM),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return GestureDetector(
                onTap: () => _openCategoryTemplates(
                  context,
                  category['category'] as TemplateCategory,
                ),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: UIStyles.spacingM),
                  child: _buildTemplateCard(
                    category['emoji'] as String,
                    category['name'] as String,
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

  /// 특정 카테고리의 템플릿 목록으로 이동
  /// @param context 빌드 컨텍스트
  /// @param category 선택한 템플릿 카테고리
  void _openCategoryTemplates(BuildContext context, TemplateCategory category) {
    // 템플릿 목록 화면으로 이동하면서 선택한 카테고리 전달
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TemplateListScreenWithCategory(category: category),
      ),
    );
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

/// 특정 카테고리의 템플릿 목록을 보여주는 화면
class TemplateListScreenWithCategory extends StatefulWidget {
  /// 선택된 템플릿 카테고리
  final TemplateCategory category;

  /// 생성자
  const TemplateListScreenWithCategory({Key? key, required this.category})
    : super(key: key);

  @override
  State<TemplateListScreenWithCategory> createState() =>
      _TemplateListScreenWithCategoryState();
}

class _TemplateListScreenWithCategoryState
    extends State<TemplateListScreenWithCategory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TemplateCategory.values.length + 1, // 모든 카테고리 + 내 템플릿
      vsync: this,
    );

    // 선택된 카테고리에 해당하는 탭으로 초기화
    _tabController.animateTo(_getCategoryIndex(widget.category));

    // 템플릿 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TemplateProvider>(context, listen: false).loadTemplates();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 카테고리에 해당하는 탭 인덱스 반환
  int _getCategoryIndex(TemplateCategory category) {
    // 첫 번째 탭은 '전체' 탭이므로 카테고리 인덱스 + 1
    return TemplateCategory.values.indexOf(category) + 1;
  }

  // 템플릿 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    TemplateModel template,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('템플릿 삭제'),
        content: const Text('정말 이 템플릿을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await Provider.of<TemplateProvider>(
          context,
          listen: false,
        ).deleteTemplate(template.id);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('템플릿이 삭제되었습니다.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category.emoji} ${widget.category.displayName} 템플릿',
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: '전체'),
            ...TemplateCategory.values.map(
              (category) =>
                  Tab(text: '${category.emoji} ${category.displayName}'),
            ),
          ],
        ),
      ),
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, child) {
          if (templateProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // 전체 템플릿 탭 (기본 템플릿만)
              _buildTemplateGrid(templateProvider.defaultTemplates),

              // 카테고리별 템플릿 탭 (기본 템플릿만)
              ...TemplateCategory.values.map(
                (category) => _buildTemplateGrid(
                  templateProvider.getDefaultTemplatesByCategory(category),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 새 템플릿 생성 화면으로 이동하고 결과 기다림
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TemplateEditScreen()),
          );

          // 템플릿이 저장되었으면 목록 새로고침
          if (result == true && mounted) {
            Provider.of<TemplateProvider>(
              context,
              listen: false,
            ).loadTemplates();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 템플릿 그리드 위젯
  Widget _buildTemplateGrid(List<TemplateModel> templates) {
    if (templates.isEmpty) {
      return const Center(child: Text('템플릿이 없습니다.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  // 템플릿 카드 위젯
  Widget _buildTemplateCard(TemplateModel template) {
    return GestureDetector(
      onTap: () async {
        // 템플릿 사용 횟수 증가
        Provider.of<TemplateProvider>(
          context,
          listen: false,
        ).incrementUsageCount(template.id);

        // 템플릿 선택 후 편집 화면으로 이동하고 결과 기다림
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TemplateEditScreen(template: template),
          ),
        );

        // 템플릿이 수정되었으면 목록 새로고침
        if (result == true && mounted) {
          Provider.of<TemplateProvider>(context, listen: false).loadTemplates();
        }
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: template.backgroundColor,
        child: Stack(
          children: [
            // 템플릿 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(template.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    template.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: template.textColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.defaultMessage,
                    style: TextStyle(fontSize: 12, color: template.textColor),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category,
                        size: 14,
                        color: template.textColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        template.category.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: template.textColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (template.usageCount > 0) ...[
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: template.textColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.usageCount}',
                          style: TextStyle(
                            fontSize: 12,
                            color: template.textColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 사용자 생성 템플릿인 경우 삭제 버튼 표시
            if (template.isUserCreated)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: template.textColor.withOpacity(0.7),
                  ),
                  onPressed: () => _showDeleteConfirmDialog(context, template),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
