import 'package:flutter/material.dart';
import 'package:test/models/template_model.dart';
import 'package:test/services/share_service.dart';
import 'package:test/utils/constants.dart';

/// 공유 카드 화면
/// 공유된 카드를 표시하는 화면
class ShareCardScreen extends StatefulWidget {
  /// 공유 ID
  final String shareId;

  /// 공유 카드 화면 생성자
  /// @param shareId 공유 ID
  /// @param key 위젯 키
  const ShareCardScreen({Key? key, required this.shareId}) : super(key: key);

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  /// 로딩 상태
  bool _isLoading = true;

  /// 오류 메시지
  String? _errorMessage;

  /// 공유 데이터
  Map<String, dynamic>? _shareData;

  /// 템플릿 모델
  TemplateModel? _template;

  /// 메시지
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadSharedData();
  }

  /// 공유 데이터 로드
  Future<void> _loadSharedData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final shareService = ShareService();
      await shareService.init();

      final shareData = await shareService.getSharedData(widget.shareId);
      if (shareData == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = '공유된 카드를 찾을 수 없습니다.';
        });
        return;
      }

      final templateData = shareData['template'] as Map<String, dynamic>;
      final template = TemplateModel.fromJson(templateData);
      final message = shareData['message'] as String;

      setState(() {
        _isLoading = false;
        _shareData = shareData;
        _template = template;
        _message = message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '카드를 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorPalette.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // 공유 기능 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('카드 공유 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  /// 본문 위젯 빌드
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadSharedData,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_template == null || _message == null) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 카드 내용
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _template!.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 이모지
                  Text(_template!.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 24),

                  // 카드 제목
                  Text(
                    _template!.name,
                    style: TextStyles.headingLarge.copyWith(
                      color: _template!.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // 카드 메시지
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _message!,
                        style: TextStyles.bodyLarge.copyWith(
                          color: _template!.textColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('돌아가기'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    // 공유 기능 구현
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('카드 공유 기능은 준비 중입니다.')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('공유하기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
