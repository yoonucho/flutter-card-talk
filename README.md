# 카드톡 (CardTalk)

감성 카드를 쉽게 만들어 소중한 사람들과 공유할 수 있는 모바일 앱입니다.

## 프로젝트 구조

카드톡은 다양한 템플릿을 활용하여 사랑, 축하, 생일, 위로, 우정, 감사 등 여러 감정을 담은 디지털 카드를 만들고 공유할 수 있는 앱입니다. 사용자 친화적인 인터페이스와 다양한 커스터마이징 옵션을 제공합니다.
```
test/
├── lib/                      # 앱 소스 코드
│   ├── main.dart             # 앱 진입점
│   ├── models/               # 데이터 모델
│   │   ├── onboarding_model.dart
│   │   └── template_model.dart
│   ├── providers/            # 상태 관리
│   │   ├── onboarding_provider.dart
│   │   └── template_provider.dart
│   ├── server/               # 로컬 서버
│   │   └── local_server.dart # 로컬 HTTP 서버 구현
│   ├── services/             # 서비스
│   │   ├── share_service.dart # 공유 서비스
│   │   └── storage_service.dart
│   ├── utils/                # 유틸리티
│   │   ├── constants.dart
│   │   └── theme.dart
│   └── views/                # UI 화면
│       ├── gallery/
│       │   └── gallery_screen.dart
│       ├── home/
│       │   └── home_screen.dart
│       ├── onboarding/
│       │   └── onboarding_screen.dart
│       ├── share/
│       │   ├── share_card_screen.dart
│       │   └── share_intro_screen.dart
│       └── template/
│           ├── template_edit_screen.dart
│           └── template_list_screen.dart
├── docs/                     # GitHub Pages 호스팅용 파일
│   ├── index.html            # 랜딩 페이지
│   ├── share.html            # 공유 링크 페이지
│   ├── view.html             # 카드 뷰어 페이지
│   ├── css/
│   │   └── styles.css        # 공통 스타일
│   └── js/
│       └── app.js            # 웹 페이지 기능
├── assets/                   # 앱 에셋
│   ├── animations/           # 애니메이션 파일
│   ├── fonts/                # 폰트 파일
│   └── images/               # 이미지 파일
├── pubspec.yaml              # Flutter 프로젝트 설정
└── README.md                 # 프로젝트 문서
```

## 주요 기능

- 다양한 템플릿으로 카드 생성
- 카드에 개인 메시지 추가
- 카드 공유 기능 (웹 링크)
- 템플릿 갤러리 및 카테고리별 분류
- 사용자 정의 템플릿 생성

## 설치 및 실행

### 요구 사항

- Flutter 3.8.0 이상
- Dart 3.8.0 이상
- Android Studio / VS Code
- Android SDK / Xcode (iOS 개발용)

### 설치 방법

1. 저장소를 클론합니다.

```bash
git clone https://github.com/yourusername/flutter-card-talk.git
cd flutter-card-talk
```

2. 의존성 패키지를 설치합니다.

```bash
flutter pub get
```

3. 앱을 실행합니다.

```bash
flutter run
```

## GitHub Pages 설정 방법

카드 공유 기능을 위해 GitHub Pages를 설정하는 방법입니다.

1. GitHub 저장소 생성 또는 기존 저장소 사용

2. `docs` 디렉토리의 파일을 저장소에 푸시

```bash
git add docs
git commit -m "Add card sharing web pages"
git push origin main
```

3. GitHub 저장소 설정에서 GitHub Pages 활성화

   - 저장소 페이지에서 Settings > Pages로 이동
   - Source를 "Deploy from a branch"로 설정
   - Branch를 "main"으로, 폴더를 "/docs"로 설정
   - Save 버튼 클릭

4. 앱 코드에서 공유 URL 업데이트

   - `lib/services/share_service.dart` 파일에서 `baseShareUrl` 값을 자신의 GitHub Pages URL로 변경

   ```dart
   static const String baseShareUrl = 'https://yoonucho.github.io/flutter-card-talk/share.html?id=';
   ```

5. 앱 빌드 및 배포

```bash
# Android APK 빌드
flutter build apk --release

# Android App Bundle 빌드 (Google Play 스토어 배포용)
flutter build appbundle --release

# iOS 빌드
flutter build ios --release

# iOS 앱 배포 준비 (Xcode에서 Archive 생성)
open ios/Runner.xcworkspace
```

### 스토어 배포

#### Google Play 스토어 배포
1. Google Play Console(https://play.google.com/console)에 로그인
2. 새 앱 만들기 또는 기존 앱 선택
3. App Bundle(aab 파일) 업로드
   - `build/app/outputs/bundle/release/app-release.aab` 파일 사용
4. 스토어 등록정보 작성 (앱 설명, 스크린샷, 아이콘 등)
5. 개인정보처리방침 URL 제공
6. 앱 출시 관리에서 출시 트랙 선택 (내부 테스트, 비공개 테스트, 공개 테스트, 프로덕션)

#### Apple App Store 배포
1. Apple Developer 계정으로 App Store Connect(https://appstoreconnect.apple.com)에 로그인
2. 새 앱 등록 또는 기존 앱 선택
3. Xcode에서 Archive 생성 후 업로드
   - Xcode > Product > Archive
   - Validate App
   - Distribute App > App Store Connect
4. App Store Connect에서 앱 정보 작성 (설명, 스크린샷, 아이콘 등)
5. 개인정보처리방침 URL 제공
6. TestFlight를 통한 테스트 또는 심사 제출

## 카드 공유 작동 방식

1. 앱에서 카드 생성 시 고유 ID 생성 및 로컬 스토리지에 저장
2. 카드 데이터를 Base64로 인코딩하여 URL 파라미터로 포함
3. 공유 링크 생성 (GitHub Pages 호스팅)
4. 수신자가 링크 접속 시:
   - 웹 브라우저: Base64 데이터를 디코딩하여 카드 표시
   - 모바일 앱: 딥 링크를 통해 앱에서 열기 가능

## 라이선스

MIT License
