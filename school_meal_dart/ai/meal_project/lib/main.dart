import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:meal_project/widgets/meal_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. JSON 파일 읽기
  final jsonFile = File('meal_data.json');
  if (!jsonFile.existsSync()) {
    print('🚨 meal_data.json 파일이 없습니다.');
    exit(1);
  }
  
  final Map<String, dynamic> mealData = jsonDecode(await jsonFile.readAsString());
  
  runApp(MyApp(mealData: mealData));
}

class MyApp extends StatefulWidget {
  final Map<String, dynamic> mealData;
  const MyApp({Key? key, required this.mealData}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    // 앱이 시작되자마자 캡처 로직 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureAndExit();
    });
  }

  Future<void> _captureAndExit() async {
    print('🎨 이미지 렌더링 및 캡처 중...');
    
    // UI가 안정화될 때까지 잠시 대기
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final imageBytes = await screenshotController.captureFromWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: Scaffold(
            body: MealCard(
              dateString: widget.mealData['dateString'],
              lunchMenu: widget.mealData['lunchMenu'],
              dinnerMenu: widget.mealData['dinnerMenu'],
            ),
          ),
        ),
        targetSize: const Size(1080, 1920), // 인스타 스토리 규격
      );

      final file = File('meal_today.png');
      await file.writeAsBytes(imageBytes);
      
      print('=====================================');
      print('🎉 이미지 저장 완료: ${file.path}');
      print('=====================================');
      
      exit(0); // 캡처 성공 후 앱 종료
    } catch (e) {
      print('❌ 캡처 중 오류 발생: $e');
      exit(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('이미지를 생성하고 있습니다...'),
            ],
          ),
        ),
      ),
    );
  }
}
