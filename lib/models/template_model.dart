import 'package:flutter/material.dart';

/// 템플릿 카테고리
/// 카드 템플릿을 분류하는 카테고리 열거형
/// 각 카테고리는 표시 이름과 대표 이모지를 가짐
enum TemplateCategory {
  love('사랑', '💕'),
  celebration('축하', '🎉'),
  birthday('생일', '🎂'),
  comfort('위로', '🤗'),
  friendship('우정', '👫'),
  gratitude('감사', '🙏');

  /// 템플릿 카테고리 생성자
  /// @param displayName 화면에 표시할 카테고리 이름
  /// @param emoji 카테고리를 대표하는 이모지
  const TemplateCategory(this.displayName, this.emoji);

  /// 화면에 표시할 카테고리 이름
  final String displayName;

  /// 카테고리를 대표하는 이모지
  final String emoji;
}

/// 템플릿 모델
/// 카드 템플릿의 정보를 담는 클래스
/// 각 템플릿은 고유 ID, 이름, 이모지, 카테고리, 배경색, 텍스트색, 기본 메시지를 가짐
class TemplateModel {
  /// 템플릿의 고유 식별자
  final String id;

  /// 템플릿의 이름
  final String name;

  /// 템플릿을 대표하는 이모지
  final String emoji;

  /// 템플릿이 속한 카테고리
  final TemplateCategory category;

  /// 템플릿의 배경색
  final Color backgroundColor;

  /// 템플릿의 텍스트 색상
  final Color textColor;

  /// 템플릿의 기본 메시지
  final String defaultMessage;

  /// 템플릿 모델 생성자
  /// @param id 템플릿 고유 ID
  /// @param name 템플릿 이름
  /// @param emoji 템플릿 이모지
  /// @param category 템플릿 카테고리
  /// @param backgroundColor 배경색
  /// @param textColor 텍스트 색상
  /// @param defaultMessage 기본 메시지
  const TemplateModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.backgroundColor,
    required this.textColor,
    required this.defaultMessage,
  });

  /// JSON으로 변환
  /// 템플릿 모델을 JSON 형식으로 직렬화
  /// @return 템플릿 정보를 담은 Map 객체
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'category': category.name,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'defaultMessage': defaultMessage,
    };
  }

  /// JSON에서 생성
  /// JSON 데이터로부터 템플릿 모델 객체 생성
  /// @param json 템플릿 정보를 담은 Map 객체
  /// @return 생성된 TemplateModel 객체
  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      category: TemplateCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      backgroundColor: Color(json['backgroundColor']),
      textColor: Color(json['textColor']),
      defaultMessage: json['defaultMessage'],
    );
  }
}

/// 기본 템플릿 데이터
/// 앱에서 기본적으로 제공하는 템플릿 데이터와 관련 기능을 담당하는 클래스
class TemplateData {
  /// 기본 제공되는 템플릿 목록
  /// 6개 카테고리(사랑, 축하, 생일, 위로, 우정, 감사)별로 각각 3개씩 총 18개의 템플릿 포함
  static const List<TemplateModel> defaultTemplates = [
    // 사랑 카테고리
    TemplateModel(
      id: 'love_001',
      name: '사랑 고백',
      emoji: '💕',
      category: TemplateCategory.love,
      backgroundColor: Color(0xFFFFE4E6),
      textColor: Color(0xFFE91E63),
      defaultMessage: '당신이 있어서 매일이 특별해요 💕',
    ),
    TemplateModel(
      id: 'love_002',
      name: '연인에게',
      emoji: '💖',
      category: TemplateCategory.love,
      backgroundColor: Color(0xFFFFF0F5),
      textColor: Color(0xFFFF1744),
      defaultMessage: '사랑해요, 오늘도 내일도 💖',
    ),
    TemplateModel(
      id: 'love_003',
      name: '로맨틱',
      emoji: '🌹',
      category: TemplateCategory.love,
      backgroundColor: Color(0xFFFFEBEE),
      textColor: Color(0xFFAD1457),
      defaultMessage: '당신과 함께하는 모든 순간이 소중해요 🌹',
    ),

    // 축하 카테고리
    TemplateModel(
      id: 'celebration_001',
      name: '축하해요',
      emoji: '🎉',
      category: TemplateCategory.celebration,
      backgroundColor: Color(0xFFFFF3E0),
      textColor: Color(0xFFFF9800),
      defaultMessage: '정말 축하해요! 🎉 당신의 성취를 함께 기뻐해요',
    ),
    TemplateModel(
      id: 'celebration_002',
      name: '성취 축하',
      emoji: '🏆',
      category: TemplateCategory.celebration,
      backgroundColor: Color(0xFFFFFDE7),
      textColor: Color(0xFFF57F17),
      defaultMessage: '대단해요! 🏆 노력의 결실을 맺었네요',
    ),
    TemplateModel(
      id: 'celebration_003',
      name: '기념일',
      emoji: '🎊',
      category: TemplateCategory.celebration,
      backgroundColor: Color(0xFFF3E5F5),
      textColor: Color(0xFF7B1FA2),
      defaultMessage: '특별한 날을 함께 축하해요! 🎊',
    ),

    // 생일 카테고리
    TemplateModel(
      id: 'birthday_001',
      name: '생일 축하',
      emoji: '🎂',
      category: TemplateCategory.birthday,
      backgroundColor: Color(0xFFE8F5E8),
      textColor: Color(0xFF2E7D32),
      defaultMessage: '생일 축하해요! 🎂 행복한 하루 되세요',
    ),
    TemplateModel(
      id: 'birthday_002',
      name: '생일 파티',
      emoji: '🎈',
      category: TemplateCategory.birthday,
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF1565C0),
      defaultMessage: '오늘은 당신의 특별한 날! 🎈 즐거운 생일 파티 되세요',
    ),
    TemplateModel(
      id: 'birthday_003',
      name: '생일 선물',
      emoji: '🎁',
      category: TemplateCategory.birthday,
      backgroundColor: Color(0xFFFCE4EC),
      textColor: Color(0xFFC2185B),
      defaultMessage: '생일 선물 같은 하루 되세요! 🎁',
    ),

    // 위로 카테고리
    TemplateModel(
      id: 'comfort_001',
      name: '위로',
      emoji: '🤗',
      category: TemplateCategory.comfort,
      backgroundColor: Color(0xFFE0F2F1),
      textColor: Color(0xFF00695C),
      defaultMessage: '힘든 시간이지만 당신 곁에 있어요 🤗',
    ),
    TemplateModel(
      id: 'comfort_002',
      name: '응원',
      emoji: '💪',
      category: TemplateCategory.comfort,
      backgroundColor: Color(0xFFE8EAF6),
      textColor: Color(0xFF3F51B5),
      defaultMessage: '당신은 충분히 잘하고 있어요! 💪 힘내세요',
    ),
    TemplateModel(
      id: 'comfort_003',
      name: '따뜻한 말',
      emoji: '☀️',
      category: TemplateCategory.comfort,
      backgroundColor: Color(0xFFFFF8E1),
      textColor: Color(0xFFFF8F00),
      defaultMessage: '어둠 뒤에는 항상 밝은 태양이 떠요 ☀️',
    ),

    // 우정 카테고리
    TemplateModel(
      id: 'friendship_001',
      name: '친구에게',
      emoji: '👫',
      category: TemplateCategory.friendship,
      backgroundColor: Color(0xFFE1F5FE),
      textColor: Color(0xFF0277BD),
      defaultMessage: '좋은 친구가 있어서 행복해요 👫',
    ),
    TemplateModel(
      id: 'friendship_002',
      name: '우정',
      emoji: '🤝',
      category: TemplateCategory.friendship,
      backgroundColor: Color(0xFFE8F5E8),
      textColor: Color(0xFF388E3C),
      defaultMessage: '언제나 든든한 친구, 고마워요 🤝',
    ),
    TemplateModel(
      id: 'friendship_003',
      name: '추억',
      emoji: '📸',
      category: TemplateCategory.friendship,
      backgroundColor: Color(0xFFF3E5F5),
      textColor: Color(0xFF8E24AA),
      defaultMessage: '함께한 추억들이 소중해요 📸',
    ),

    // 감사 카테고리
    TemplateModel(
      id: 'gratitude_001',
      name: '감사 인사',
      emoji: '🙏',
      category: TemplateCategory.gratitude,
      backgroundColor: Color(0xFFEDE7F6),
      textColor: Color(0xFF512DA8),
      defaultMessage: '정말 감사해요 🙏 당신의 도움이 큰 힘이 되었어요',
    ),
    TemplateModel(
      id: 'gratitude_002',
      name: '고마워요',
      emoji: '💝',
      category: TemplateCategory.gratitude,
      backgroundColor: Color(0xFFFFF3E0),
      textColor: Color(0xFFEF6C00),
      defaultMessage: '마음 깊이 고마워요 💝',
    ),
    TemplateModel(
      id: 'gratitude_003',
      name: '감사 표현',
      emoji: '🌟',
      category: TemplateCategory.gratitude,
      backgroundColor: Color(0xFFF9FBE7),
      textColor: Color(0xFF689F38),
      defaultMessage: '당신 덕분에 더 빛나는 하루예요 🌟',
    ),
  ];

  /// 카테고리별 템플릿 가져오기
  /// 지정된 카테고리에 속하는 모든 템플릿을 반환
  /// @param category 조회할 템플릿 카테고리
  /// @return 해당 카테고리의 템플릿 목록
  static List<TemplateModel> getTemplatesByCategory(TemplateCategory category) {
    return defaultTemplates
        .where((template) => template.category == category)
        .toList();
  }

  /// 모든 카테고리 가져오기
  /// 사용 가능한 모든 템플릿 카테고리 목록 반환
  /// @return 모든 템플릿 카테고리 목록
  static List<TemplateCategory> getAllCategories() {
    return TemplateCategory.values;
  }

  /// 인기 템플릿 가져오기 (각 카테고리에서 첫 번째 템플릿)
  /// 각 카테고리별로 대표 템플릿 하나씩을 모아서 반환
  /// @return 카테고리별 대표 템플릿 목록
  static List<TemplateModel> getPopularTemplates() {
    final popularTemplates = <TemplateModel>[];
    for (final category in TemplateCategory.values) {
      final categoryTemplates = getTemplatesByCategory(category);
      if (categoryTemplates.isNotEmpty) {
        popularTemplates.add(categoryTemplates.first);
      }
    }
    return popularTemplates;
  }
}
