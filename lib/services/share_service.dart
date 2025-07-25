import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:test/models/template_model.dart';

/// 카드 공유 서비스
/// 카드를 저장하고 공유 링크를 생성하는 기능을 제공
class ShareService {
  /// 싱글톤 인스턴스
  static final ShareService _instance = ShareService._internal();

  /// SharedPreferences 인스턴스
  late SharedPreferences _prefs;

  /// 기본 공유 URL (GitHub Pages)
  static const String baseShareUrl =
      'https://yoonucho.github.io/flutter-card-talk/share.html';

  /// 싱글톤 패턴 구현
  /// 항상 같은 인스턴스를 반환하도록 팩토리 생성자 사용
  /// @return ShareService 싱글톤 인스턴스
  factory ShareService() => _instance;

  /// 내부 생성자
  /// 외부에서 직접 인스턴스 생성을 방지
  ShareService._internal();

  /// 서비스 초기화
  /// SharedPreferences 인스턴스를 초기화
  /// @return Future<void> 초기화 완료 Future
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 카드 저장 및 공유 링크 생성
  /// @param template 공유할 카드 템플릿
  /// @param message 카드에 포함될 메시지
  /// @return Future<String> 생성된 공유 링크
  Future<String> createShareLink(TemplateModel template, String message) async {
    try {
      // 고유 ID 생성
      final uuid = const Uuid().v4();

      // 공유 데이터 생성
      final shareData = {
        'id': uuid,
        'template': template.toJson(),
        'message': message,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 로컬 스토리지에 데이터 저장
      await _prefs.setString('share_$uuid', jsonEncode(shareData));

      // URL 파라미터로 전달할 간단한 데이터 생성
      final urlData = {
        'name': template.name,
        'emoji': template.emoji,
        'message': message,
        'backgroundColor':
            '# [${template.backgroundColor.value.toRadixString(16).substring(2)}',
        'textColor':
            '# [${template.textColor.value.toRadixString(16).substring(2)}',
      };
      print('urlData: $urlData');
      final jsonStr = jsonEncode(urlData);
      print('jsonStr: $jsonStr');
      final utf8Bytes = utf8.encode(jsonStr);
      print('utf8Bytes: $utf8Bytes');
      // 데이터를 Base64로 인코딩
      final encodedData = base64Encode(utf8Bytes);
      // 공백/줄바꿈 제거
      final cleanedData = encodedData.replaceAll(RegExp(r'\s+'), '');
      print('base64: $encodedData');
      // URL 안전하게 인코딩 (+ → -, / → _, = 제거)
      final urlSafeData = Uri.encodeComponent(cleanedData);

      // 공유 링크 생성
      final shareLink = '${baseShareUrl}?id=$uuid&data=$urlSafeData';

      return shareLink;
    } catch (e) {
      debugPrint('공유 링크 생성 중 오류 발생: $e');
      rethrow;
    }
  }

  /// 공유 데이터 조회
  /// @param id 공유 ID
  /// @return Map<String, dynamic>? 공유 데이터, 없으면 null 반환
  Future<Map<String, dynamic>?> getSharedData(String id) async {
    try {
      final data = _prefs.getString('share_$id');
      if (data == null) {
        return null;
      }

      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('공유 데이터 조회 중 오류 발생: $e');
      return null;
    }
  }

  /// 모든 공유 데이터 조회
  /// @return List<Map<String, dynamic>> 모든 공유 데이터 목록
  Future<List<Map<String, dynamic>>> getAllSharedData() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith('share_'));
      final result = <Map<String, dynamic>>[];

      for (final key in keys) {
        final data = _prefs.getString(key);
        if (data != null) {
          result.add(jsonDecode(data) as Map<String, dynamic>);
        }
      }

      // 생성일 기준 내림차순 정렬
      result.sort((a, b) {
        final aDate = DateTime.parse(a['createdAt'] as String);
        final bDate = DateTime.parse(b['createdAt'] as String);
        return bDate.compareTo(aDate);
      });

      return result;
    } catch (e) {
      debugPrint('모든 공유 데이터 조회 중 오류 발생: $e');
      return [];
    }
  }

  /// 공유 데이터 삭제
  /// @param id 삭제할 공유 ID
  /// @return Future<bool> 삭제 성공 여부
  Future<bool> deleteSharedData(String id) async {
    try {
      return await _prefs.remove('share_$id');
    } catch (e) {
      debugPrint('공유 데이터 삭제 중 오류 발생: $e');
      return false;
    }
  }
}
