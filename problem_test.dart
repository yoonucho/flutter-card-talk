import 'dart:convert';

void main() {
  // 문제가 발생했던 URL의 data 파라미터
  final problemData =
      "eyJuYW1lIjoi7IOd7J28IOyEoOusvCIsImVtb2ppIjoi8J%20OgSIsIm1lc3NhZ2UiOiLsg53snbwg7ISg66y8IOqwmeydgCDtlZjro6gg65CY7IS47JqUIeOFjuOFjuOFjuOFjiDwn46BIiwiYmFja2dyb3VuZENvbG9yIjoiI2ZjZTRlYyIsInRleHRDb2xvciI6IiNjMjE4NWIifQ==";

  print('문제 데이터:');
  print(problemData);
  print('\n');

  try {
    // 1. URL 디코딩
    print('1. URL 디코딩 시도...');
    final urlDecoded = Uri.decodeComponent(problemData);
    print('URL 디코딩 결과:');
    print(urlDecoded);
    print('\n');

    // 2. Base64 디코딩
    print('2. Base64 디코딩 시도...');
    // 패딩 확인
    var base64Str = urlDecoded;
    if (base64Str.length % 4 != 0) {
      print('패딩 추가 필요');
      while (base64Str.length % 4 != 0) {
        base64Str += '=';
      }
    }

    // 공백 문자 처리 (URL에서 %20으로 인코딩된 부분)
    base64Str = base64Str.replaceAll(' ', '+');

    print('수정된 Base64 문자열:');
    print(base64Str);
    print('\n');

    final decodedBytes = base64Decode(base64Str);
    final jsonStr = utf8.decode(decodedBytes);
    print('JSON 문자열:');
    print(jsonStr);
    print('\n');

    // 3. JSON 파싱
    final jsonData = jsonDecode(jsonStr);
    print('파싱된 데이터:');
    print(jsonData);
  } catch (e) {
    print('오류 발생: $e');
  }
}
