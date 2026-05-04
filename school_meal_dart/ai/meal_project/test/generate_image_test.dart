import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_project/widgets/meal_card.dart';

void main() {
  testWidgets('급식 데이터를 가져와 인스타 스토리 이미지를 렌더링합니다', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    final jsonFile = File('meal_data.json');
    if (!jsonFile.existsSync()) {
      throw Exception('meal_data.json 파일이 없습니다.');
    }
    
    final mealData = jsonDecode(await jsonFile.readAsString());
    
    final repaintBoundaryKey = GlobalKey();

    final widget = MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: RepaintBoundary(
          key: repaintBoundaryKey,
          child: MealCard(
            dateString: mealData['dateString'],
            lunchMenu: mealData['lunchMenu'],
            dinnerMenu: mealData['dinnerMenu'],
          ),
        ),
      ),
    );

    await tester.pumpWidget(widget);
    await tester.pump(const Duration(seconds: 1)); 

    // 직접 RepaintBoundary에서 이미지 추출하여 저장
    RenderRepaintBoundary boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    
    File('meal_today.png').writeAsBytesSync(pngBytes);
    print('🎉 이미지 저장 완료: meal_today.png');
    
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
