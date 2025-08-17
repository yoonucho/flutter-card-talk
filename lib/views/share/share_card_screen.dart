import 'package:flutter/material.dart';
import 'package:test/models/template_model.dart';
import 'package:test/services/share_service.dart';
import 'package:test/utils/constants.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

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

class _ShareCardScreenState extends State<ShareCardScreen>
    with TickerProviderStateMixin {
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

  /// 색종이 애니메이션 컨트롤러
  late ConfettiController _confettiController;

  /// 카드 애니메이션 컨트롤러
  late AnimationController _cardAnimationController;

  /// 카드 스케일 애니메이션
  late Animation<double> _cardScaleAnimation;

  /// 카드가 나타났는지 여부
  bool _cardRevealed = false;

  @override
  void initState() {
    super.initState();
    
    // 색종이 애니메이션 컨트롤러 초기화
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    // 카드 애니메이션 컨트롤러 초기화
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 카드 스케일 애니메이션 설정
    _cardScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _loadSharedData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
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

      // 카드가 로드되면 애니메이션 시작
      _startRevealAnimation();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '카드를 불러오는 중 오류가 발생했습니다: $e';
      });
    }
  }

  /// 카드 공개 애니메이션 시작
  void _startRevealAnimation() {
    if (!_cardRevealed) {
      setState(() {
        _cardRevealed = true;
      });
      
      // 카드 스케일 애니메이션 시작
      _cardAnimationController.forward();
      
      // 약간의 지연 후 색종이 애니메이션 시작
      Future.delayed(const Duration(milliseconds: 500), () {
        _confettiController.play();
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorPalette.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSharedData,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 카드 내용
                Expanded(
                  child: AnimatedBuilder(
                    animation: _cardScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _cardScaleAnimation.value,
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
                      );
                    },
                  ),
                ),

                // 하단 버튼
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('돌아가기'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // 애니메이션 다시 재생
                          _cardAnimationController.reset();
                          _confettiController.stop();
                          setState(() {
                            _cardRevealed = false;
                          });
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _startRevealAnimation();
                          });
                        },
                        icon: const Icon(Icons.celebration),
                        label: const Text('다시 보기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
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
          ),

          // 색종이 애니메이션 - 상단
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // 아래쪽으로
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
                Colors.pink,
              ],
            ),
          ),

          // 색종이 애니메이션 - 좌상단
          Align(
            alignment: Alignment.topLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 4, // 우하단으로
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.03,
              numberOfParticles: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),

          // 색종이 애니메이션 - 우상단
          Align(
            alignment: Alignment.topRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3 * pi / 4, // 좌하단으로
              maxBlastForce: 15,
              minBlastForce: 8,
              emissionFrequency: 0.03,
              numberOfParticles: 20,
              gravity: 0.3,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
