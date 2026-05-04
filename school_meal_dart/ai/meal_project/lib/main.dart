import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:meal_project/widgets/meal_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. JSON 폴더에서 가장 최근 파일 읽기
  final jsonDir = Directory('json_data');
  if (!jsonDir.existsSync()) {
    print('🚨 json_data 폴더가 없습니다.');
    exit(1);
  }
  
  final files = jsonDir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList();
  if (files.isEmpty) {
    print('🚨 json_data 폴더에 JSON 파일이 없습니다.');
    exit(1);
  }
  
  // 이름(날짜) 기준으로 가장 최신 파일 정렬
  files.sort((a, b) => b.path.compareTo(a.path));
  final jsonFile = files.first;
  
  print('📄 읽어온 데이터 파일: ${jsonFile.path}');
  
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
      final dateStr = widget.mealData['dateString'] as String;
      final cleanDate = dateStr.replaceAll(RegExp(r'[^0-9]'), ''); // "20260506"
      final dir = Directory('images');
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      } else {
        // 기존 캡처본 청소
        for (var file in dir.listSync()) {
          if (file is File && file.path.endsWith('.png')) {
            file.deleteSync();
          }
        }
      }

      // 1. 중식 캡처
      final lunchBytes = await screenshotController.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1080, 1920)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              child: MealCard(
                isLunch: true,
                dateString: widget.mealData['dateString'],
                menu: widget.mealData['lunchMenu'],
              ),
            ),
          ),
        ),
        targetSize: const Size(1080, 1920),
      );
      final lunchFile = File('images/${cleanDate}_lunch.png');
      await lunchFile.writeAsBytes(lunchBytes);
      print('☀️ 중식 이미지 저장 완료: ${lunchFile.path}');

      // 2. 석식 캡처
      final dinnerBytes = await screenshotController.captureFromWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1080, 1920)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              child: MealCard(
                isLunch: false,
                dateString: widget.mealData['dateString'],
                menu: widget.mealData['dinnerMenu'],
              ),
            ),
          ),
        ),
        targetSize: const Size(1080, 1920),
      );
      final dinnerFile = File('images/${cleanDate}_dinner.png');
      await dinnerFile.writeAsBytes(dinnerBytes);
      print('🌙 석식 이미지 저장 완료: ${dinnerFile.path}');

      print('=====================================');
      print('🎉 모든 이미지 렌더링 및 저장 완료!');
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
