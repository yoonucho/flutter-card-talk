import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// 온보딩 상태 관리 Provider
/// 사용자의 온보딩 완료 상태를 관리하고 상태 변경 시 UI에 알림
class OnboardingProvider extends ChangeNotifier {
  /// 로컬 저장소 서비스
  final StorageService _storageService;

  /// 온보딩 완료 상태
  bool _isOnboardingCompleted = false;

  /// 데이터 로딩 상태
  bool _isLoading = true;

  /// OnboardingProvider 생성자
  /// @param storageService 초기화된 저장소 서비스
  /// 생성 시 자동으로 온보딩 상태를 확인
  OnboardingProvider(this._storageService) {
    _checkOnboardingStatus();
  }

  /// 온보딩 완료 여부 반환
  /// @return 온보딩 완료 여부
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  /// 로딩 상태 반환
  /// @return 데이터 로딩 중 여부
  bool get isLoading => _isLoading;

  /// 온보딩 상태 확인
  /// 저장소에서 온보딩 완료 상태를 읽어와 상태 업데이트
  void _checkOnboardingStatus() {
    _isOnboardingCompleted = _storageService.isOnboardingCompleted();
    _isLoading = false;
    notifyListeners();
  }

  /// 온보딩 완료 처리
  /// 온보딩 완료 상태를 저장소에 저장하고 상태 업데이트
  /// @return Future 완료 객체
  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  /// 온보딩 초기화 (테스트용)
  /// 온보딩 완료 상태를 초기화하고 상태 업데이트
  /// @return Future 완료 객체
  Future<void> resetOnboarding() async {
    await _storageService.setOnboardingCompleted(false);
    _isOnboardingCompleted = false;
    notifyListeners();
  }
}
