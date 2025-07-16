import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 저장소 서비스
class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  // 싱글톤 패턴 구현
  factory StorageService() => _instance;

  StorageService._internal();

  /// 서비스 초기화
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 온보딩 완료 여부 저장
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool('onboarding_completed', value);
  }

  /// 온보딩 완료 여부 확인
  bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  /// 사용자 선호 테마 저장
  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString('theme_mode', themeMode);
  }

  /// 사용자 선호 테마 확인
  String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'light';
  }
}
