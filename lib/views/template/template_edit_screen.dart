import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:test/models/template_model.dart';
import 'package:test/providers/template_provider.dart';
import 'package:test/services/share_service.dart';
import 'package:test/utils/constants.dart';

/// 템플릿 편집 화면
/// 템플릿을 생성하거나 수정할 수 있는 화면
class TemplateEditScreen extends StatefulWidget {
  /// 편집할 템플릿 (새 템플릿 생성 시 null)
  final TemplateModel? template;

  /// 템플릿 편집 화면 생성자
  /// @param template 편집할 템플릿 (새 템플릿 생성 시 null)
  /// @param key 위젯 키
  const TemplateEditScreen({Key? key, this.template}) : super(key: key);

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen> {
  // 폼 키
  final _formKey = GlobalKey<FormState>();

  // 텍스트 컨트롤러
  late TextEditingController _nameController;
  late TextEditingController _emojiController;
  late TextEditingController _messageController;

  // 선택된 카테고리
  late TemplateCategory _selectedCategory;

  // 선택된 색상
  late Color _backgroundColor;
  late Color _textColor;

  // 로딩 상태
  bool _isLoading = false;

  // 공유 링크
  String? _shareLink;
  bool _showShareLink = false;

  // 저장된 템플릿
  TemplateModel? _template;

  // 저장 여부
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();

    // 기존 템플릿이 있으면 해당 값으로 초기화, 없으면 기본값 사용
    final template = widget.template;
    // 기존에 저장된 템플릿인 경우에만 _isSaved를 true로 설정
    _isSaved = template?.id != null;
    _template = template;

    _nameController = TextEditingController(text: template?.name ?? '');

    _emojiController = TextEditingController(text: template?.emoji ?? '😊');

    _messageController = TextEditingController(
      text: template?.defaultMessage ?? '',
    );

    _selectedCategory = template?.category ?? TemplateCategory.love;

    _backgroundColor = template?.backgroundColor ?? const Color(0xFFFFE4E6);
    _textColor = template?.textColor ?? const Color(0xFFE91E63);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // 템플릿 저장
  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _showShareLink = false;
      _shareLink = null;
    });

    try {
      final templateProvider = Provider.of<TemplateProvider>(
        context,
        listen: false,
      );

      // 템플릿 데이터 생성
      final template = TemplateModel(
        id:
            widget.template?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        emoji: _emojiController.text,
        category: _selectedCategory,
        backgroundColor: _backgroundColor,
        textColor: _textColor,
        defaultMessage: _messageController.text,
        isUserCreated: true,
        usageCount: widget.template?.usageCount ?? 0,
      );

      // 기존 템플릿 수정 또는 새 템플릿 추가
      if (widget.template != null) {
        await templateProvider.updateTemplate(template);
      } else {
        await templateProvider.addTemplate(template);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _template = template; // 저장된 템플릿 참조 저장
          _isSaved = true; // 저장 완료 플래그 설정
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.template != null ? '카드가 수정되었습니다.' : '새 카드가 추가되었습니다.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 공유 링크 생성
  Future<void> _createShareLink() async {
    if (_template == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 카드를 저장해주세요.')));
      return;
    }

    setState(() {
      _isLoading = true;
      _showShareLink = false;
      _shareLink = null;
    });

    try {
      // 공유 링크 생성
      final shareService = ShareService();
      await shareService.init();
      final link = await shareService.createShareLink(
        _template!,
        _messageController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _showShareLink = true;
          _shareLink = link;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('공유 링크 생성 중 오류가 발생했습니다: $e')));

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 색상 선택 다이얼로그 표시
  void _showColorPicker({required bool isBackgroundColor}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isBackgroundColor ? '배경색 선택' : '텍스트 색상 선택'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: isBackgroundColor ? _backgroundColor : _textColor,
            onColorChanged: (color) {
              setState(() {
                if (isBackgroundColor) {
                  _backgroundColor = color;
                } else {
                  _textColor = color;
                }
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsvWithHue,
            labelTypes: const [ColorLabelType.hex, ColorLabelType.rgb],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 공유 링크 복사
  void _copyShareLink() {
    if (_shareLink != null) {
      Clipboard.setData(ClipboardData(text: _shareLink!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('공유 링크가 클립보드에 복사되었습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSaved ? '카드 수정' : '카드 만들기'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveTemplate,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 템플릿 미리보기
            Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _emojiController.text.isEmpty
                          ? '😊'
                          : _emojiController.text,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty
                          ? '카드 이름'
                          : _nameController.text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _messageController.text.isEmpty
                            ? '카드 메시지를 입력하세요.'
                            : _messageController.text,
                        style: TextStyle(fontSize: 16, color: _textColor),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 공유 링크 표시
            if (_showShareLink && _shareLink != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          '카드가 성공적으로 저장되었습니다!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('아래 링크를 통해 카드를 공유할 수 있습니다:'),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _shareLink!,
                              style: const TextStyle(fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: _copyShareLink,
                            tooltip: '링크 복사',
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 템플릿 이름
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '카드 이름',
                hintText: '카드 이름을 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '카드 이름을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 이모지 선택
            TextFormField(
              controller: _emojiController,
              decoration: const InputDecoration(
                labelText: '대표 이모지',
                hintText: '대표 이모지를 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이모지를 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 카테고리 선택
            DropdownButtonFormField<TemplateCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: TemplateCategory.values.map((category) {
                return DropdownMenuItem<TemplateCategory>(
                  value: category,
                  child: Text('${category.emoji} ${category.displayName}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // 색상 선택
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showColorPicker(isBackgroundColor: true),
                    icon: const Icon(Icons.format_color_fill),
                    label: const Text('배경색 선택'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _backgroundColor,
                      foregroundColor: _backgroundColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showColorPicker(isBackgroundColor: false),
                    icon: const Icon(Icons.format_color_text),
                    label: const Text('텍스트 색상'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _textColor,
                      foregroundColor: _textColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 기본 메시지
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: '카드 메시지',
                hintText: '카드에 담을 메시지를 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '메시지를 입력하세요';
                }
                return null;
              },
              maxLines: 5,
            ),

            // 저장 버튼
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveTemplate,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? '저장 중...' : '카드 저장'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createShareLink,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share),
                    label: Text(_isLoading ? '생성 중...' : '공유 링크 생성'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: ColorPalette.secondaryMint,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
