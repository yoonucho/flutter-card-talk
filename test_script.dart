import 'dart:convert';

void main() {
  // 테스트용 카드 데이터
  final cardData = {
    'name': '테스트 카드',
    'emoji': '💌',
    'message': '안녕하세요! 테스트 메시지입니다.',
    'backgroundColor': '#fce4ec',
    'textColor': '#c2185b',
  };

  print('원본 JSON 데이터:');
  print(cardData);
  print('\n');

  // 1. JSON 인코딩
  final jsonString = jsonEncode(cardData);
  print('JSON 문자열:');
  print(jsonString);
  print('\n');

  // 2. Base64 인코딩
  final base64Encoded = base64Encode(utf8.encode(jsonString));
  print('Base64 인코딩:');
  print(base64Encoded);
  print('\n');

  // 3. URL 안전 인코딩 (방법 1: 문자 치환)
  final urlSafeBase64 = base64Encoded
      .replaceAll('+', '-')
      .replaceAll('/', '_')
      .replaceAll('=', '');
  print('URL 안전 Base64 (방법 1):');
  print(urlSafeBase64);
  print('\n');

  // 4. URL 안전 인코딩 (방법 2: Uri.encodeComponent)
  final urlEncoded = Uri.encodeComponent(base64Encoded);
  print('URL 안전 Base64 (방법 2):');
  print(urlEncoded);
  print('\n');

  // 테스트: 디코딩
  print('===== 디코딩 테스트 =====');

  // 방법 1 디코딩
  var decoded1 = urlSafeBase64;
  // '+', '/' 복원 및 패딩 추가
  decoded1 = decoded1.replaceAll('-', '+').replaceAll('_', '/');
  while (decoded1.length % 4 != 0) {
    decoded1 += '=';
  }

  final decodedJson1 = utf8.decode(base64Decode(decoded1));
  print('방법 1 디코딩 결과:');
  print(decodedJson1);
  print('\n');

  // 방법 2 디코딩
  var decoded2 = Uri.decodeComponent(urlEncoded);
  final decodedJson2 = utf8.decode(base64Decode(decoded2));
  print('방법 2 디코딩 결과:');
  print(decodedJson2);
}
