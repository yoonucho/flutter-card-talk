import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 저장소 서비스
/// 앱의 설정 및 상태를 로컬에 저장하고 불러오는 기능을 제공
/// 싱글톤 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 사용
class StorageService {
  /// 싱글톤 인스턴스
  static final StorageService _instance = StorageService._internal();

  /// SharedPreferences 인스턴스
  late SharedPreferences _prefs;

  /// 싱글톤 패턴 구현
  /// 항상 같은 인스턴스를 반환하도록 팩토리 생성자 사용
  /// @return StorageService 싱글톤 인스턴스
  factory StorageService() => _instance;

  /// 내부 생성자
  /// 외부에서 직접 인스턴스 생성을 방지
  StorageService._internal();

  /// 서비스 초기화
  /// SharedPreferences 인스턴스를 초기화
  /// @return Future<void> 초기화 완료 Future
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 온보딩 완료 여부 저장
  /// 사용자의 온보딩 완료 상태를 로컬에 저장
  /// @param value 온보딩 완료 여부
  /// @return Future<void> 저장 완료 Future
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool('onboarding_completed', value);
  }

  /// 온보딩 완료 여부 확인
  /// 저장된 온보딩 완료 상태를 반환, 없으면 기본값 false 반환
  /// @return bool 온보딩 완료 여부
  bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  /// 사용자 선호 테마 저장
  /// 사용자가 선택한 테마 모드를 로컬에 저장
  /// @param themeMode 테마 모드 ('light', 'dark', 'system' 중 하나)
  /// @return Future<void> 저장 완료 Future
  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString('theme_mode', themeMode);
  }

  /// 사용자 선호 테마 확인
  /// 저장된 테마 모드를 반환, 없으면 기본값 'light' 반환
  /// @return String 테마 모드
  String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'light';
  }
}
