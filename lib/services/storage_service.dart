import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  /// 일반 데이터 저장
  /// 키-값 쌍으로 데이터를 로컬에 저장
  /// 복잡한 객체는 JSON으로 직렬화하여 저장
  /// @param key 저장할 데이터의 키
  /// @param value 저장할 데이터 값
  /// @return Future<void> 저장 완료 Future
  Future<void> setItem(String key, dynamic value) async {
    try {
      if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else {
        // 복잡한 객체는 JSON으로 직렬화
        // 명시적으로 Map이나 List를 새로 생성하여 불변 객체 문제 방지
        final jsonString = jsonEncode(value);
        await _prefs.setString(key, jsonString);
      }
    } catch (e) {
      debugPrint('데이터 저장 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 데이터 조회
  /// 저장된 데이터를 키를 통해 조회
  /// 복잡한 객체는 JSON에서 역직렬화하여 반환
  /// @param key 조회할 데이터의 키
  /// @return dynamic 저장된 데이터 값, 없으면 null 반환
  dynamic getItem(String key) {
    final value = _prefs.get(key);
    if (value == null) {
      return null;
    }

    // 문자열인 경우 JSON 역직렬화 시도
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (e) {
        // JSON이 아닌 일반 문자열인 경우 그대로 반환
        return value;
      }
    }

    return value;
  }

  /// 데이터 삭제
  /// 지정된 키에 해당하는 데이터를 삭제
  /// @param key 삭제할 데이터의 키
  /// @return Future<bool> 삭제 성공 여부
  Future<bool> removeItem(String key) async {
    return await _prefs.remove(key);
  }

  /// 모든 데이터 삭제
  /// 저장된 모든 데이터를 삭제
  /// @return Future<bool> 삭제 성공 여부
  Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
