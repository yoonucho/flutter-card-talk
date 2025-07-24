import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as path;
import 'package:test/services/share_service.dart';

/// 로컬 서버 클래스
/// 공유 링크를 처리하기 위한 간단한 로컬 서버
class LocalServer {
  /// 서버 인스턴스
  HttpServer? _server;

  /// 서버 포트
  final int port;

  /// 공유 서비스
  final ShareService _shareService = ShareService();

  /// 로컬 서버 생성자
  /// @param port 서버 포트 (기본값: 8080)
  LocalServer({this.port = 8080}) {
    _shareService.init();
  }

  /// 서버 시작
  /// @return Future<void> 서버 시작 완료 Future
  Future<void> start() async {
    final app = Router();

    // 정적 파일 핸들러 (HTML, CSS, JS 등)
    final staticHandler = createStaticHandler('assets/web');

    // 공유 링크 핸들러
    app.get('/share/<id>', _handleShareRequest);

    // 웹 뷰어 핸들러
    app.get('/view/<id>', _handleViewRequest);

    // API 엔드포인트
    app.get('/api/card/<id>', _handleCardApiRequest);

    // 기본 라우트 핸들러
    app.all('/<ignored|.*>', (request) {
      return staticHandler(request);
    });

    // 미들웨어 설정
    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addHandler(app);

    // 서버 시작
    _server = await io.serve(handler, '0.0.0.0', port);
    print('로컬 서버가 시작되었습니다: http://localhost:$port');
  }

  /// 공유 링크 요청 처리
  /// @param request HTTP 요청
  /// @param id 공유 ID
  /// @return shelf.Response HTTP 응답
  shelf.Response _handleShareRequest(shelf.Request request, String id) {
    final htmlContent =
        '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>카드톡 - 공유 카드</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 0;
          padding: 0;
          background-color: #ffccd5;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
        }
        .container {
          text-align: center;
          padding: 20px;
        }
        .title {
          font-size: 24px;
          color: #333;
          margin-bottom: 20px;
        }
        .message {
          font-size: 18px;
          color: #555;
          margin-bottom: 30px;
        }
        .button {
          background-color: #ff9aac;
          color: white;
          border: none;
          padding: 12px 24px;
          border-radius: 20px;
          font-size: 16px;
          cursor: pointer;
          text-decoration: none;
          display: inline-block;
        }
        .button:hover {
          background-color: #e57b92;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="title">특별한 카드가 도착했어요!</div>
        <div class="message">카드톡 앱에서 확인해보세요.</div>
        <a href="cardtalk://share/$id" class="button">카드 열기 (앱)</a>
        <div style="margin-top: 20px;">
          <a href="https://yoonucho.github.io/flutter-card-talk/view.html?id=$id" class="button" style="background-color: #4CAF50;">웹에서 보기</a>
        </div>
      </div>
      <script>
        // 앱으로 이동 시도
        function tryOpenApp() {
          // 앱 스키마로 이동 시도
          window.location.href = "cardtalk://share/$id";
          
          // 일정 시간 후에도 페이지가 여전히 열려있으면 앱이 설치되지 않은 것
          setTimeout(function() {
            // 웹 버전으로 이동
            window.location.href = "https://yoonucho.github.io/flutter-card-talk/view.html?id=$id";
          }, 2000);
        }
        
        // 페이지 로드 시 자동으로 앱 열기 시도
        window.onload = function() {
          // 사용자 경험을 위해 자동 실행은 비활성화하고 버튼 클릭으로 처리
          // tryOpenApp();
        };
      </script>
    </body>
    </html>
    ''';

    return shelf.Response.ok(
      htmlContent,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  }

  /// 웹 뷰어 요청 처리
  /// @param request HTTP 요청
  /// @param id 공유 ID
  /// @return shelf.Response HTTP 응답
  shelf.Response _handleViewRequest(shelf.Request request, String id) {
    final htmlContent =
        '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>특별한 카드가 도착했어요</title>
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        
        body {
          font-family: 'Noto Sans KR', sans-serif;
          background-color: #ffccd5;
          display: flex;
          justify-content: center;
          align-items: center;
          min-height: 100vh;
          overflow: hidden;
          transition: background-color 0.5s ease;
        }
        
        .container {
          width: 100%;
          max-width: 500px;
          text-align: center;
          padding: 20px;
          position: relative;
        }
        
        .intro-container {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          z-index: 10;
          background-color: #ffccd5;
          transition: opacity 1s ease;
        }
        
        .intro-text {
          font-size: 24px;
          font-weight: 700;
          color: #e91e63;
          margin-bottom: 40px;
          opacity: 0;
          transform: translateY(20px);
          transition: opacity 0.5s ease, transform 0.5s ease;
        }
        
        .intro-text.show {
          opacity: 1;
          transform: translateY(0);
        }
        
        .intro-subtext {
          font-size: 16px;
          color: #666;
          margin-bottom: 30px;
          opacity: 0;
          transform: translateY(20px);
          transition: opacity 0.5s ease, transform 0.5s ease;
        }
        
        .intro-subtext.show {
          opacity: 1;
          transform: translateY(0);
        }
        
        .intro-button {
          background-color: transparent;
          color: #e91e63;
          border: none;
          padding: 0;
          font-size: 48px;
          line-height: 1;
          display: flex;
          align-items: center;
          justify-content: center;
          cursor: pointer;
          transform: scale(0.9);
          transition: transform 0.3s ease;
          opacity: 0;
          animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
          0% {
            transform: scale(0.95);
            opacity: 0.7;
          }
          
          70% {
            transform: scale(1.1);
            opacity: 1;
          }
          
          100% {
            transform: scale(0.95);
            opacity: 0.7;
          }
        }
        
        .intro-button.show {
          opacity: 1;
        }
        
        .intro-button:hover {
          transform: scale(1.2);
        }
        
        .card-container {
          opacity: 0;
          transition: opacity 1s ease;
        }
        
        .card {
          background-color: white;
          border-radius: 24px;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
          padding: 40px 30px;
          text-align: center;
          transform: translateY(20px);
          opacity: 0;
          position: relative;
          overflow: hidden;
          transition: all 0.5s ease;
        }
        
        .card.show {
          transform: translateY(0);
          opacity: 1;
        }
        
        .emoji {
          font-size: 72px;
          margin-bottom: 24px;
          display: inline-block;
          transform: scale(0);
          transition: transform 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275) 0.3s;
        }
        
        .card.show .emoji {
          transform: scale(1);
        }
        
        .title {
          font-size: 28px;
          font-weight: 700;
          color: #e91e63;
          margin-bottom: 24px;
          opacity: 0;
          transform: translateY(20px);
          transition: all 0.5s ease 0.5s;
        }
        
        .card.show .title {
          opacity: 1;
          transform: translateY(0);
        }
        
        .message {
          font-size: 18px;
          line-height: 1.8;
          margin-bottom: 30px;
          white-space: pre-wrap;
          opacity: 0;
          transform: translateY(20px);
          transition: all 0.5s ease 0.7s;
        }
        
        .card.show .message {
          opacity: 1;
          transform: translateY(0);
        }
        
        .footer {
          margin-top: 40px;
          font-size: 14px;
          color: rgba(0, 0, 0, 0.5);
          opacity: 0;
          transition: opacity 0.5s ease 1s;
        }
        
        .card.show .footer {
          opacity: 1;
        }
        
        .logo {
          display: flex;
          align-items: center;
          justify-content: center;
          margin-top: 16px;
          font-weight: 500;
          color: #666;
          opacity: 0;
          transition: opacity 0.5s ease 1.2s;
        }
        
        .card-container.show .logo {
          opacity: 1;
        }
        
        #loading {
          text-align: center;
          padding: 40px;
        }
        
        .spinner {
          display: inline-block;
          width: 40px;
          height: 40px;
          border: 4px solid rgba(255, 154, 172, 0.3);
          border-radius: 50%;
          border-top-color: #ff9aac;
          animation: spin 1s ease-in-out infinite;
        }
        
        @keyframes spin {
          to { transform: rotate(360deg); }
        }
        
        #error {
          background-color: #fff3f3;
          color: #e53935;
          text-align: center;
          padding: 20px;
          border-radius: 8px;
          box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
          display: none;
        }
        
        .error-icon {
          font-size: 48px;
          margin-bottom: 16px;
        }
        
        .confetti {
          position: absolute;
          width: 10px;
          height: 10px;
          background-color: #ff9aac;
          opacity: 0;
        }
        
        .heart {
          position: absolute;
          width: 20px;
          height: 20px;
          background-color: #ff9aac;
          transform: rotate(45deg);
          opacity: 0;
        }
        
        .heart:before,
        .heart:after {
          content: "";
          position: absolute;
          width: 20px;
          height: 20px;
          background-color: #ff9aac;
          border-radius: 50%;
        }
        
        .heart:before {
          top: -10px;
          left: 0;
        }
        
        .heart:after {
          top: 0;
          left: -10px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <!-- 인트로 화면 -->
        <div class="intro-container" id="intro">
          <div class="intro-text" id="introText">특별한 카드가 도착했어요!</div>
          <div class="intro-subtext" id="introSubtext">아래 버튼을 눌러 확인하세요</div>
          <button class="intro-button" id="introButton">❤️</button>
        </div>
        
        <!-- 카드 화면 -->
        <div class="card-container" id="cardContainer">
          <div id="loading">
            <div class="spinner"></div>
            <p>카드 정보를 불러오는 중입니다...</p>
          </div>
          
          <div id="error">
            <div class="error-icon">⚠️</div>
            <h3>카드를 불러올 수 없습니다</h3>
            <p>카드 정보를 불러오는데 실패했습니다.</p>
            <button onclick="location.reload()">다시 시도</button>
          </div>
          
          <div id="card" class="card" style="display: none;">
            <div id="emoji" class="emoji">💌</div>
            <div id="title" class="title">카드 제목</div>
            <div id="message" class="message">카드 메시지</div>
            <div class="footer">
              <p>소중한 마음이 담긴 카드입니다</p>
            </div>
          </div>
          
          <div class="logo">
            <span>카드톡으로 제작된 카드입니다</span>
          </div>
        </div>
      </div>
      
      <script>
        // 인트로 애니메이션
        document.addEventListener('DOMContentLoaded', function() {
          setTimeout(() => {
            document.getElementById('introText').classList.add('show');
          }, 500);
          
          setTimeout(() => {
            document.getElementById('introSubtext').classList.add('show');
          }, 800);
          
          setTimeout(() => {
            document.getElementById('introButton').classList.add('show');
          }, 1200);
          
          // 인트로 버튼 클릭 이벤트
          document.getElementById('introButton').addEventListener('click', function() {
            // 인트로 화면 숨기기
            document.getElementById('intro').style.opacity = '0';
            
            // 카드 화면 표시
            document.getElementById('cardContainer').style.opacity = '1';
            
            // 인트로 화면 완전히 제거
            setTimeout(() => {
              document.getElementById('intro').style.display = 'none';
              
              // 카드 데이터 가져오기
              loadCardData();
            }, 1000);
            
            // 하트 효과 생성
            createHearts();
          });
        });
        
        // 하트 효과 생성
        function createHearts() {
          const container = document.querySelector('.container');
          
          for (let i = 0; i < 20; i++) {
            const heart = document.createElement('div');
            heart.className = 'heart';
            
            // 랜덤 위치
            heart.style.left = Math.random() * 100 + '%';
            heart.style.top = Math.random() * 100 + '%';
            
            // 랜덤 크기
            const size = Math.random() * 15 + 10;
            heart.style.width = size + 'px';
            heart.style.height = size + 'px';
            
            // 하트 크기에 맞게 before, after 요소 크기 조정
            heart.style.setProperty('--size', size + 'px');
            
            // 랜덤 색상
            const colors = ['#ff9aac', '#ff6b8b', '#ff3e6d', '#ff1e4d'];
            const color = colors[Math.floor(Math.random() * colors.length)];
            heart.style.backgroundColor = color;
            
            container.appendChild(heart);
            
            // 애니메이션
            heart.animate([
              { 
                opacity: 0,
                transform: 'rotate(45deg) translate(0, 0) scale(0)'
              },
              { 
                opacity: 0.8,
                transform: 'rotate(45deg) translate(0, -100px) scale(1)'
              },
              { 
                opacity: 0,
                transform: 'rotate(45deg) translate(0, -200px) scale(0.5)'
              }
            ], {
              duration: Math.random() * 2000 + 1000,
              delay: Math.random() * 500,
              easing: 'ease-out',
              iterations: 1
            });
            
            // 애니메이션 후 요소 제거
            setTimeout(() => {
              heart.remove();
            }, 3000);
          }
        }
        
        // 카드 데이터 가져오기
        function loadCardData() {
          fetch('/api/card/$id')
            .then(response => {
              if (!response.ok) {
                throw new Error('카드 정보를 불러오는데 실패했습니다.');
              }
              return response.json();
            })
            .then(data => {
              // 카드 데이터 표시
              document.getElementById('emoji').textContent = data.emoji || '💌';
              document.getElementById('title').textContent = data.name || '카드 제목';
              document.getElementById('message').textContent = data.message || '카드 메시지';
              
              // 카드 스타일 설정
              const card = document.getElementById('card');
              card.style.backgroundColor = data.backgroundColor || '#ffffff';
              
              // 텍스트 색상 설정
              document.getElementById('title').style.color = data.textColor || '#e91e63';
              document.getElementById('message').style.color = data.textColor || '#333333';
              
              // 로딩 숨기고 카드 표시
              document.getElementById('loading').style.display = 'none';
              document.getElementById('card').style.display = 'block';
              
              // 애니메이션 효과
              setTimeout(() => {
                document.getElementById('card').classList.add('show');
                document.getElementById('cardContainer').classList.add('show');
                createConfetti();
              }, 100);
            })
            .catch(error => {
              console.error('Error:', error);
              document.getElementById('loading').style.display = 'none';
              document.getElementById('error').style.display = 'block';
            });
        }
        
        // 색종이 효과
        function createConfetti() {
          const card = document.getElementById('card');
          const colors = ['#ff9aac', '#a8e6cf', '#ffd3b6', '#d4a5ff', '#ffccd5'];
          
          for (let i = 0; i < 50; i++) {
            const confetti = document.createElement('div');
            confetti.className = 'confetti';
            confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
            confetti.style.left = Math.random() * 100 + '%';
            confetti.style.top = -20 + 'px';
            confetti.style.width = Math.random() * 8 + 5 + 'px';
            confetti.style.height = Math.random() * 8 + 5 + 'px';
            confetti.style.opacity = Math.random();
            confetti.style.transform = 'rotate(' + Math.random() * 360 + 'deg)';
            
            card.appendChild(confetti);
            
            // 애니메이션
            const delay = Math.random() * 3;
            const duration = Math.random() * 3 + 2;
            
            confetti.animate([
              { transform: 'translate(0, 0) rotate(0deg)', opacity: 1 },
              { transform: 'translate(' + (Math.random() * 200 - 100) + 'px, ' + (Math.random() * 200 + 100) + 'px) rotate(' + Math.random() * 360 + 'deg)', opacity: 0 }
            ], {
              duration: duration * 1000,
              delay: delay * 1000,
              fill: 'forwards'
            });
            
            // 애니메이션 후 요소 제거
            setTimeout(() => {
              confetti.remove();
            }, (delay + duration) * 1000);
          }
        }
      </script>
    </body>
    </html>
    ''';

    return shelf.Response.ok(
      htmlContent,
      headers: {'Content-Type': 'text/html; charset=utf-8'},
    );
  }

  /// 카드 API 요청 처리
  /// @param request HTTP 요청
  /// @param id 공유 ID
  /// @return shelf.Response HTTP 응답
  Future<shelf.Response> _handleCardApiRequest(
    shelf.Request request,
    String id,
  ) async {
    try {
      // 공유 데이터 조회
      final shareData = await _shareService.getSharedData(id);
      if (shareData == null) {
        return shelf.Response.notFound('카드를 찾을 수 없습니다.');
      }

      // 템플릿 데이터와 메시지 추출
      final template = shareData['template'] as Map<String, dynamic>;
      final message = shareData['message'] as String;

      // 색상 처리 (16진수 문자열로 변환)
      final backgroundColor =
          '#${(template['backgroundColor'] as int).toRadixString(16).padLeft(8, '0').substring(2)}';
      final textColor =
          '#${(template['textColor'] as int).toRadixString(16).padLeft(8, '0').substring(2)}';

      // 응답 데이터 생성
      final responseData = {
        'id': id,
        'name': template['name'],
        'emoji': template['emoji'],
        'message': message,
        'backgroundColor': backgroundColor,
        'textColor': textColor,
        'createdAt': shareData['createdAt'],
      };

      return shelf.Response.ok(
        jsonEncode(responseData),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
    } catch (e) {
      print('카드 API 요청 처리 중 오류 발생: $e');
      return shelf.Response.internalServerError(
        body: jsonEncode({'error': '카드 정보를 불러오는데 실패했습니다.'}),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );
    }
  }

  /// 정적 파일 핸들러 생성
  /// @param dirPath 정적 파일 디렉토리 경로
  /// @return shelf.Handler 정적 파일 핸들러
  shelf.Handler createStaticHandler(String dirPath) {
    return (request) {
      final requestPath = request.url.path.isEmpty
          ? 'index.html'
          : request.url.path;
      final filePath = path.join(dirPath, requestPath);

      try {
        final file = File(filePath);
        if (file.existsSync()) {
          final content = file.readAsBytesSync();
          final contentType = _getContentType(filePath);

          return shelf.Response.ok(
            content,
            headers: {'Content-Type': contentType},
          );
        }
      } catch (e) {
        print('정적 파일 처리 중 오류 발생: $e');
      }

      return shelf.Response.notFound('File not found');
    };
  }

  /// 파일 확장자에 따른 Content-Type 반환
  /// @param filePath 파일 경로
  /// @return String Content-Type
  String _getContentType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();

    switch (ext) {
      case '.html':
        return 'text/html; charset=utf-8';
      case '.css':
        return 'text/css; charset=utf-8';
      case '.js':
        return 'application/javascript; charset=utf-8';
      case '.json':
        return 'application/json; charset=utf-8';
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.svg':
        return 'image/svg+xml';
      default:
        return 'text/plain; charset=utf-8';
    }
  }

  /// 서버 종료
  /// @return Future<void> 서버 종료 완료 Future
  Future<void> stop() async {
    await _server?.close();
    _server = null;
    print('로컬 서버가 종료되었습니다.');
  }
}
