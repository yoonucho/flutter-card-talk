import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/models/template_model.dart';
import 'package:test/providers/template_provider.dart';
import 'package:test/views/template/template_edit_screen.dart';

/// 템플릿 목록 화면
/// 모든 템플릿을 카테고리별로 보여주는 화면
class TemplateListScreen extends StatefulWidget {
  /// 템플릿 목록 화면 생성자
  /// @param key 위젯 키
  const TemplateListScreen({Key? key}) : super(key: key);

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: TemplateCategory.values.length + 1, // 모든 카테고리 + 내 템플릿
      vsync: this,
    );

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
        title: const Text('템플릿 목록'),
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
              // 전체 템플릿 탭
              _buildTemplateGrid(templateProvider.templates),

              // 카테고리별 템플릿 탭
              ...TemplateCategory.values.map(
                (category) => _buildTemplateGrid(
                  templateProvider.getTemplatesByCategory(category),
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
