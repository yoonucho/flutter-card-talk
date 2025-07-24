import 'dart:convert';

void main() {
  // 이모지가 포함된 테스트 데이터
  final testData = {
    'name': '이모지 테스트',
    'emoji': '💌', // 이모지
    'message': '안녕하세요! 💕 테스트입니다.',
  };

  print('원본 데이터:');
  print(testData);
  print('\n');

  // 1. JSON 문자열로 변환
  final jsonStr = jsonEncode(testData);
  print('JSON 문자열:');
  print(jsonStr);
  print('\n');

  // 2. UTF-8 인코딩 확인
  final utf8Bytes = utf8.encode(jsonStr);
  print('UTF-8 바이트:');
  print(utf8Bytes);
  print('\n');

  // 3. Base64 인코딩
  final base64Str = base64Encode(utf8Bytes);
  print('Base64 인코딩:');
  print(base64Str);
  print('\n');

  // 4. URL 인코딩 (Uri.encodeComponent)
  final urlEncoded = Uri.encodeComponent(base64Str);
  print('URL 인코딩:');
  print(urlEncoded);
  print('\n');

  // 5. URL 디코딩
  final urlDecoded = Uri.decodeComponent(urlEncoded);
  print('URL 디코딩:');
  print(urlDecoded);
  print('\n');

  // 6. Base64 디코딩
  final base64Decoded = utf8.decode(base64Decode(urlDecoded));
  print('Base64 디코딩:');
  print(base64Decoded);
  print('\n');

  // 7. JSON 파싱
  final jsonDecoded = jsonDecode(base64Decoded);
  print('JSON 파싱:');
  print(jsonDecoded);
  print('\n');

  // 8. 원본과 비교
  print('원본과 일치: ${jsonStr == base64Decoded}');
}
