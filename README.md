# 카드톡 (CardTalk)

감성 카드를 쉽게 만들어 소중한 사람들과 공유할 수 있는 모바일 앱입니다.

## 📱 프로젝트 소개

카드톡은 다양한 템플릿을 활용하여 사랑, 축하, 생일, 위로, 우정, 감사 등 여러 감정을 담은 디지털 카드를 만들고 공유할 수 있는 앱입니다. 사용자 친화적인 인터페이스와 다양한 커스터마이징 옵션을 제공합니다.

## 🛠️ 기술 스택

- **프레임워크**: Flutter
- **상태 관리**: Provider
- **데이터 저장**: SharedPreferences
- **언어**: Dart
- **폰트**: Yangjin

## 📂 프로젝트 구조

```
lib/
├── main.dart                  # 앱 진입점
├── models/                    # 데이터 모델
│   ├── onboarding_model.dart  # 온보딩 데이터 모델
│   └── template_model.dart    # 템플릿 데이터 모델
├── providers/                 # 상태 관리
│   ├── onboarding_provider.dart  # 온보딩 상태 관리
│   └── template_provider.dart    # 템플릿 상태 관리
├── services/                  # 서비스
│   └── storage_service.dart   # 로컬 저장소 서비스
├── utils/                     # 유틸리티
│   ├── constants.dart         # 앱 상수 (색상, 스타일 등)
│   └── theme.dart             # 앱 테마 설정
└── views/                     # UI 화면
    ├── gallery/               # 갤러리 화면
    │   └── gallery_screen.dart
    ├── home/                  # 홈 화면
    │   └── home_screen.dart
    ├── onboarding/            # 온보딩 화면
    │   └── onboarding_screen.dart
    └── template/              # 템플릿 관련 화면
        ├── template_edit_screen.dart  # 템플릿 편집 화면
        └── template_list_screen.dart  # 템플릿 목록 화면
```

## 📝 작업 단계

### 1. 프로젝트 초기 설정

- Flutter 프로젝트 생성
- 기본 폴더 구조 설정 (models, providers, services, utils, views)
- pubspec.yaml 구성 및 필요 패키지 추가 (provider, shared_preferences)
- 앱 테마 및 상수 정의 (colors, text styles, UI styles)

### 2. 데이터 모델 구현

- **TemplateModel**: 템플릿 데이터 모델 구현
  - 6개 카테고리(사랑, 축하, 생일, 위로, 우정, 감사)별 각 3개씩 총 18개 기본 템플릿 정의
  - JSON 직렬화/역직렬화 기능 구현
  - 카테고리별 템플릿 조회, 인기 템플릿 조회 기능 구현
- **OnboardingModel**: 온보딩 화면 데이터 모델 구현
  - 4개의 온보딩 페이지 정의 (환영, 템플릿 선택, 카드 만들기, 공유하기)

### 3. 서비스 구현

- **StorageService**: 로컬 저장소 서비스 구현
  - SharedPreferences를 활용한 데이터 저장 및 조회 기능
  - 온보딩 완료 상태 관리
  - 사용자 템플릿 저장 및 조회 기능
  - 앱 설정 저장 기능

### 4. 상태 관리 구현

- **OnboardingProvider**: 온보딩 상태 관리 Provider 구현
  - 온보딩 완료 여부 확인 및 설정
  - 온보딩 초기화 기능 (테스트용)
- **TemplateProvider**: 템플릿 상태 관리 Provider 구현
  - 기본 템플릿 및 사용자 템플릿 로드
  - 템플릿 추가, 수정, 삭제 기능
  - 템플릿 사용 횟수 관리

### 5. 앱 기본 구조 구현

- **main.dart**: 앱 진입점 및 라우팅 구현
  - Provider 설정
  - 테마 적용
  - 라우트 정의
  - 스플래시 화면 구현
  - 온보딩 상태에 따른 초기 화면 결정 로직

## 🚀 다음 단계 계획

- 온보딩 화면 UI 구현
- 홈 화면 UI 구현
- 템플릿 목록 및 편집 화면 구현
- 갤러리 화면 구현
- 템플릿 공유 기능 구현
- 데이터베이스 Supabase 연결
