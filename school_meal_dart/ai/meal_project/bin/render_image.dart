import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:meal_project/widgets/meal_card.dart';

void main() async {
  // 1. 데이터 읽기
  final jsonFile = File('meal_data.json');
  if (!jsonFile.existsSync()) {
    print('🚨 meal_data.json 파일이 없습니다. 먼저 daily_meal.dart를 실행하세요.');
    exit(1);
  }
  
  final Map<String, dynamic> mealData = jsonDecode(await jsonFile.readAsString());
  
  print('🎨 이미지 렌더링을 시작합니다...');

  // 2. 스크린샷 컨트롤러 생성
  final screenshotController = ScreenshotController();

  // 3. 위젯을 이미지로 캡처 (비화면 렌더링)
  // 💡 captureFromWidget은 화면에 띄우지 않고도 메모리 상에서 위젯을 그려 이미지로 만들어줍니다.
  try {
    final imageBytes = await screenshotController.captureFromWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(
          body: MealCard(
            dateString: mealData['dateString'],
            lunchMenu: mealData['lunchMenu'],
            dinnerMenu: mealData['dinnerMenu'],
          ),
        ),
      ),
      targetSize: const Size(1080, 1920), // 인스타 스토리 규격
      delay: const Duration(seconds: 1), // 폰트나 이미지가 로딩될 시간을 조금 줍니다.
    );

    // 4. 파일 저장
    final file = File('meal_today.png');
    await file.writeAsBytes(imageBytes);

    print('=====================================');
    print('🎉 이미지 생성 성공: ${file.path}');
    print('📐 사이즈: 1080 x 1920');
    print('=====================================');
    
    exit(0);
  } catch (e) {
    print('❌ 이미지 생성 중 오류 발생: $e');
    exit(1);
  }
}
