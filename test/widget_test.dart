// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/services/storage_service.dart';

import 'package:test/main.dart';

/// 앱 위젯 테스트 모음
void main() {
  /// 앱 시작 테스트
  /// 앱이 정상적으로 시작되고 스플래시 화면이 표시되는지 확인하는 테스트
  testWidgets('App 시작 테스트', (WidgetTester tester) async {
    // StorageService 초기화
    final storageService = StorageService();
    await storageService.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(storageService: storageService));

    // 스플래시 화면이 표시되는지 확인
    // '카드톡' 텍스트와 '💌' 이모지가 화면에 있어야 함
    expect(find.text('카드톡'), findsOneWidget);
    expect(find.text('💌'), findsOneWidget);

    // 잠시 기다린 후 온보딩 화면이 나타나는지 확인
    // 애니메이션 및 비동기 작업 완료 대기
    await tester.pumpAndSettle();

    // 온보딩 화면의 요소들이 있는지 확인 (온보딩이 완료되지 않은 상태)
    // 또는 홈 화면이 표시되는지 확인 (온보딩이 완료된 상태)
    // 최소한 Scaffold 위젯은 존재해야 함
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
