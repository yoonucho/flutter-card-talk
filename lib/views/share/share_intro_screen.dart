import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:test/utils/constants.dart';
import 'package:test/views/share/share_card_screen.dart';

/// 공유 인트로 화면
/// 공유 링크를 통해 접근했을 때 보여주는 인트로 화면
class ShareIntroScreen extends StatefulWidget {
  /// 공유 ID
  final String shareId;

  /// 공유 인트로 화면 생성자
  /// @param shareId 공유 ID
  /// @param key 위젯 키
  const ShareIntroScreen({Key? key, required this.shareId}) : super(key: key);

  @override
  State<ShareIntroScreen> createState() => _ShareIntroScreenState();
}

class _ShareIntroScreenState extends State<ShareIntroScreen>
    with SingleTickerProviderStateMixin {
  /// 애니메이션 컨트롤러
  late AnimationController _controller;

  /// 텍스트 애니메이션
  late Animation<double> _textAnimation;

  /// 버튼 애니메이션
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 텍스트 애니메이션 설정
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 버튼 애니메이션 설정
    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // 애니메이션 시작
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.primaryLightPink,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 애니메이션 이미지
              Expanded(
                flex: 3,
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/gift_animation.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 텍스트 영역
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _textAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '특별한 카드가 도착했어요',
                        style: TextStyles.headingLarge.copyWith(
                          color: ColorPalette.primaryPink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          '소중한 마음이 담긴 카드를 확인해보세요',
                          style: TextStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 버튼 영역
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _buttonAnimation,
                  child: ScaleTransition(
                    scale: _buttonAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ShareCardScreen(shareId: widget.shareId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primaryPink,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.card_giftcard, size: 24),
                            const SizedBox(width: 8),
                            Text('카드 열기', style: TextStyles.buttonLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
