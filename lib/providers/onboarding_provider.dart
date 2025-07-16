import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// 온보딩 상태 관리 Provider
class OnboardingProvider extends ChangeNotifier {
  final StorageService _storageService;
  bool _isOnboardingCompleted = false;
  bool _isLoading = true;

  OnboardingProvider(this._storageService) {
    _checkOnboardingStatus();
  }

  /// 온보딩 완료 여부 반환
  bool get isOnboardingCompleted => _isOnboardingCompleted;

  /// 로딩 상태 반환
  bool get isLoading => _isLoading;

  /// 온보딩 상태 확인
  void _checkOnboardingStatus() {
    _isOnboardingCompleted = _storageService.isOnboardingCompleted();
    _isLoading = false;
    notifyListeners();
  }

  /// 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted(true);
    _isOnboardingCompleted = true;
    notifyListeners();
  }

  /// 온보딩 초기화 (테스트용)
  Future<void> resetOnboarding() async {
    await _storageService.setOnboardingCompleted(false);
    _isOnboardingCompleted = false;
    notifyListeners();
  }
}
