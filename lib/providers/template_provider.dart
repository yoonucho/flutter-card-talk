import 'package:flutter/foundation.dart';
import 'package:test/models/template_model.dart';
import 'package:test/services/storage_service.dart';

class TemplateProvider with ChangeNotifier {
  final StorageService _storageService;
  List<TemplateModel> _templates = [];
  List<TemplateModel> _userTemplates = [];
  bool _isLoading = false;

  TemplateProvider(this._storageService) {
    loadTemplates();
  }

  bool get isLoading => _isLoading;
  List<TemplateModel> get templates => [..._templates];
  List<TemplateModel> get userTemplates => [..._userTemplates];

  // 모든 템플릿 로드 (기본 템플릿 + 사용자 템플릿)
  Future<void> loadTemplates() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 기본 템플릿 로드 - 새 리스트에 복사
      _templates = List<TemplateModel>.from(
        TemplateModel.getDefaultTemplates(),
      );

      // 사용자 템플릿 로드
      final userTemplatesData = await _storageService.getItem('user_templates');
      if (userTemplatesData != null) {
        final List<dynamic> decodedData = userTemplatesData;
        _userTemplates = decodedData
            .map((item) => TemplateModel.fromJson(item))
            .toList();

        // 사용자 템플릿을 전체 템플릿 목록에 추가
        _templates.addAll(_userTemplates);
      }
    } catch (e) {
      debugPrint('템플릿 로드 중 오류 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 카테고리별 템플릿 조회
  List<TemplateModel> getTemplatesByCategory(TemplateCategory category) {
    return _templates
        .where((template) => template.category == category)
        .toList();
  }

  // 새 템플릿 추가
  Future<void> addTemplate(TemplateModel template) async {
    try {
      // 새 ID 생성 (현재 시간 기반)
      final newTemplate = TemplateModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: template.name,
        emoji: template.emoji,
        category: template.category,
        backgroundColor: template.backgroundColor,
        textColor: template.textColor,
        defaultMessage: template.defaultMessage,
        isUserCreated: true, // 항상 사용자 생성 템플릿으로 설정
        usageCount: 0,
      );

      _userTemplates.add(newTemplate);
      _templates.add(newTemplate);

      await _saveUserTemplates();
      notifyListeners();
    } catch (e) {
      debugPrint('템플릿 추가 중 오류 발생: $e');
      rethrow;
    }
  }

  // 템플릿 수정
  Future<void> updateTemplate(TemplateModel template) async {
    try {
      final index = _templates.indexWhere((t) => t.id == template.id);
      if (index >= 0) {
        // 기본 템플릿은 수정할 수 없음
        if (!_templates[index].isUserCreated) {
          // 기본 템플릿을 수정하려면 복사본을 만들어 사용자 템플릿으로 저장
          final newTemplate = TemplateModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: template.name,
            emoji: template.emoji,
            category: template.category,
            backgroundColor: template.backgroundColor,
            textColor: template.textColor,
            defaultMessage: template.defaultMessage,
            isUserCreated: true, // 항상 사용자 생성 템플릿으로 설정
            usageCount: 0,
          );

          // 새 리스트를 생성하여 추가
          List<TemplateModel> newUserTemplates = List<TemplateModel>.from(
            _userTemplates,
          );
          newUserTemplates.add(newTemplate);
          _userTemplates = newUserTemplates;

          List<TemplateModel> newTemplates = List<TemplateModel>.from(
            _templates,
          );
          newTemplates.add(newTemplate);
          _templates = newTemplates;
        } else {
          // 사용자 템플릿 수정
          List<TemplateModel> newTemplates = List<TemplateModel>.from(
            _templates,
          );
          newTemplates[index] = template;
          _templates = newTemplates;

          final userIndex = _userTemplates.indexWhere(
            (t) => t.id == template.id,
          );
          if (userIndex >= 0) {
            List<TemplateModel> newUserTemplates = List<TemplateModel>.from(
              _userTemplates,
            );
            newUserTemplates[userIndex] = template;
            _userTemplates = newUserTemplates;
          }
        }

        await _saveUserTemplates();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('템플릿 수정 중 오류 발생: $e');
      rethrow;
    }
  }

  // 템플릿 삭제
  Future<void> deleteTemplate(String id) async {
    try {
      final template = _templates.firstWhere((t) => t.id == id);

      // 기본 템플릿은 삭제할 수 없음
      if (!template.isUserCreated) {
        throw Exception('기본 템플릿은 삭제할 수 없습니다.');
      }

      // 새 리스트를 생성하여 항목 제거
      _templates = _templates.where((t) => t.id != id).toList();
      _userTemplates = _userTemplates.where((t) => t.id != id).toList();

      await _saveUserTemplates();
      notifyListeners();
    } catch (e) {
      debugPrint('템플릿 삭제 중 오류 발생: $e');
      rethrow;
    }
  }

  // 템플릿 사용 횟수 증가
  Future<void> incrementUsageCount(String id) async {
    try {
      final index = _templates.indexWhere((t) => t.id == id);
      if (index >= 0) {
        final template = _templates[index];
        final updatedTemplate = template.copyWith(
          usageCount: template.usageCount + 1,
        );

        // 새 리스트를 생성하여 수정
        List<TemplateModel> newTemplates = List<TemplateModel>.from(_templates);
        newTemplates[index] = updatedTemplate;
        _templates = newTemplates;

        // 사용자 템플릿인 경우 사용자 템플릿 목록도 업데이트
        if (template.isUserCreated) {
          final userIndex = _userTemplates.indexWhere((t) => t.id == id);
          if (userIndex >= 0) {
            List<TemplateModel> newUserTemplates = List<TemplateModel>.from(
              _userTemplates,
            );
            newUserTemplates[userIndex] = updatedTemplate;
            _userTemplates = newUserTemplates;
          }
          await _saveUserTemplates();
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('템플릿 사용 횟수 증가 중 오류 발생: $e');
    }
  }

  // 사용자 템플릿 저장
  Future<void> _saveUserTemplates() async {
    try {
      // 명시적으로 새 리스트를 생성하여 불변 리스트 문제 방지
      final List<Map<String, dynamic>> userTemplatesJson = [];
      for (var template in _userTemplates) {
        userTemplatesJson.add(template.toJson());
      }

      await _storageService.setItem('user_templates', userTemplatesJson);
    } catch (e) {
      debugPrint('사용자 템플릿 저장 중 오류 발생: $e');
      rethrow;
    }
  }
}
