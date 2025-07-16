import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/models/template_model.dart';
import 'package:test/providers/template_provider.dart';
import 'package:test/views/template/template_edit_screen.dart';

/// 갤러리 화면
/// 사용자가 만들거나 수정한 템플릿을 보여주는 화면
class GalleryScreen extends StatefulWidget {
  /// 갤러리 화면 생성자
  /// @param key 위젯 키
  const GalleryScreen({Key? key}) : super(key: key);

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
    // 템플릿 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TemplateProvider>(context, listen: false).loadTemplates();
    });
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
      appBar: AppBar(title: const Text('내 갤러리')),
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, child) {
          if (templateProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 사용자가 만든 템플릿만 필터링
          final userTemplates = templateProvider.userTemplates;

          if (userTemplates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '아직 만든 템플릿이 없습니다.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '템플릿을 수정하거나 새로 만들어보세요!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (context) => const TemplateEditScreen(),
                            ),
                          )
                          .then((result) {
                            if (result == true) {
                              Provider.of<TemplateProvider>(
                                context,
                                listen: false,
                              ).loadTemplates();
                            }
                          });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('새 템플릿 만들기'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: userTemplates.length,
            itemBuilder: (context, index) {
              final template = userTemplates[index];
              return _buildTemplateCard(template);
            },
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

            // 삭제 버튼
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
