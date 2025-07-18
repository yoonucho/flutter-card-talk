import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'services/share_service.dart';
import 'server/local_server.dart';
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

  // 로컬 서버 시작
  final localServer = LocalServer();
  try {
    await localServer.start();
  } catch (e) {
    print('로컬 서버 시작 중 오류 발생: $e');
  }

  // 앱 종료 시 로컬 서버 종료
  ProcessSignal.sigint.watch().listen((_) async {
    await localServer.stop();
    exit(0);
  });

  ProcessSignal.sigterm.watch().listen((_) async {
    await localServer.stop();
    exit(0);
  });

  // 앱 실행
  runApp(
    MyApp(
      storageService: storageService,
      shareService: shareService,
      localServer: localServer,
    ),
  );
}

/// 앱의 루트 위젯
/// 앱의 전체 구조와 테마, 라우팅을 설정
class MyApp extends StatefulWidget {
  /// 로컬 저장소 서비스
  final StorageService storageService;

  /// 공유 서비스
  final ShareService shareService;

  /// 로컬 서버
  final LocalServer localServer;

  /// MyApp 생성자
  /// @param storageService 초기화된 저장소 서비스
  /// @param shareService 초기화된 공유 서비스
  /// @param localServer 초기화된 로컬 서버
  const MyApp({
    super.key,
    required this.storageService,
    required this.shareService,
    required this.localServer,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// 초기 링크
  String? _initialLink;

  /// 초기 URI
  Uri? _initialUri;

  /// 라우터 키
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  /// 딥 링크 초기화 및 처리
  Future<void> _initUniLinks() async {
    // 앱이 실행 중이지 않을 때 열린 링크 처리
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _initialLink = initialLink;
        _initialUri = Uri.parse(initialLink);
        _handleLink(_initialUri!);
      }
    } on PlatformException {
      // 딥 링크를 가져오는 중 오류 발생
      print('딥 링크를 가져오는 중 오류가 발생했습니다.');
    }

    // 앱이 실행 중일 때 열린 링크 처리
    linkStream.listen(
      (String? link) {
        if (link != null) {
          final uri = Uri.parse(link);
          _handleLink(uri);
        }
      },
      onError: (err) {
        // 딥 링크 스트림 오류 처리
        print('딥 링크 스트림 오류: $err');
      },
    );
  }

  /// 링크 처리
  void _handleLink(Uri uri) {
    // cardtalk://share/{id} 형식의 링크 처리
    if (uri.scheme == 'cardtalk' && uri.host == 'share') {
      final shareId = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.first
          : null;
      if (shareId != null) {
        // 공유 화면으로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigatorKey.currentState?.pushNamed('/share/$shareId');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 앱 전체에서 사용할 Provider 등록
      providers: [
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider(widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TemplateProvider(widget.storageService),
        ),
      ],
      child: MaterialApp(
        title: '카드톡',
        theme: getAppTheme(),
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
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
