import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/share_service.dart';
import 'providers/onboarding_provider.dart';
import 'providers/template_provider.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/home/home_screen.dart';
import 'views/template/template_list_screen.dart';
import 'views/template/template_edit_screen.dart';
import 'views/gallery/gallery_screen.dart';
import 'views/share/share_intro_screen.dart';
import 'utils/theme.dart';

/// 앱의 시작점
/// 앱 초기화 및 실행을 담당
void main() async {
  // Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // StorageService 초기화
  final storageService = StorageService();
  await storageService.init();

  // ShareService 초기화
  final shareService = ShareService();
  await shareService.init();

  // 앱 실행
  runApp(MyApp(storageService: storageService, shareService: shareService));
}

/// 앱의 루트 위젯
/// 앱의 전체 구조와 테마, 라우팅을 설정
class MyApp extends StatelessWidget {
  /// 로컬 저장소 서비스
  final StorageService storageService;

  /// 공유 서비스
  final ShareService shareService;

  /// MyApp 생성자
  /// @param storageService 초기화된 저장소 서비스
  /// @param shareService 초기화된 공유 서비스
  const MyApp({
    super.key,
    required this.storageService,
    required this.shareService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 앱 전체에서 사용할 Provider 등록
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(storageService),
        ),
        ChangeNotifierProvider(create: (_) => TemplateProvider(storageService)),
      ],
      child: MaterialApp(
        title: '카드톡',
        theme: getAppTheme(),
        debugShowCheckedModeBanner: false,
        home: const AppRouter(),
        // 앱 내 라우트 정의
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/home': (context) => const HomeScreen(),
          '/templates': (context) => const TemplateListScreen(),
          '/template/new': (context) => const TemplateEditScreen(),
          '/gallery': (context) => const GalleryScreen(),
        },
        // 동적 라우팅 처리
        onGenerateRoute: (settings) {
          // 공유 링크 처리
          if (settings.name?.startsWith('/share/') == true) {
            final shareId = settings.name!.substring('/share/'.length);
            return MaterialPageRoute(
              builder: (context) => ShareIntroScreen(shareId: shareId),
            );
          }
          return null;
        },
      ),
    );
  }
}

/// 앱 라우팅 관리 위젯
/// 온보딩 완료 여부에 따라 적절한 화면으로 라우팅
class AppRouter extends StatelessWidget {
  /// AppRouter 생성자
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        // 로딩 중일 때 스플래시 화면 표시
        if (onboardingProvider.isLoading) {
          return const SplashScreen();
        }

        // 온보딩 완료 여부에 따라 화면 결정
        if (onboardingProvider.isOnboardingCompleted) {
          return const HomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}

/// 스플래시 화면 위젯
/// 앱 시작 시 로딩 중에 표시되는 화면
class SplashScreen extends StatelessWidget {
  /// SplashScreen 생성자
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 로고 이모지
            Text('💌', style: TextStyle(fontSize: 80)),
            SizedBox(height: 16),
            // 앱 이름
            Text(
              '카드톡',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9AAC),
              ),
            ),
            SizedBox(height: 32),
            // 로딩 인디케이터
            CircularProgressIndicator(color: Color(0xFFFF9AAC)),
          ],
        ),
      ),
    );
  }
}
