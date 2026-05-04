import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:meal_project/api/neis_api.dart';
import 'package:meal_project/scraper/school_board.dart';
import 'package:meal_project/parser/excel_parser.dart';

void main() async {
  // [1] 날짜 설정
  final targetDate = DateTime.now(); 

  final dateString = DateFormat('yyyy년 MM월 dd일').format(targetDate);
  
  final cleanDate = DateFormat('yyyyMMdd').format(targetDate);
  final jsonDir = Directory('json_data');
  if (!jsonDir.existsSync()) {
    jsonDir.createSync(recursive: true);
  }
  
  final jsonPath = 'json_data/$cleanDate.json';
  if (File(jsonPath).existsSync()) {
    print('✅ 이미 $cleanDate 일자의 데이터가 존재합니다. 수집을 건너뜁니다.');
    return;
  }

  print('=====================================');
  print('🏫 통합 급식 수집 시스템 (중식 & 석식)');
  print('📅 타겟 날짜: $dateString');
  print('=====================================\n');

  // [2] 중식 수집 (나이스 API)
  print('🔄 [1/2] 나이스 API에서 중식을 가져오는 중...');
  String lunchMenu = await NeisApi.fetchLunch(targetDate);
  if (lunchMenu.contains('INFO-200') || lunchMenu.isEmpty) {
    lunchMenu = '오늘은 중식이 없습니다.';
  }

  // [3] 석식 수집 (학교 게시판 크롤링 & 파이썬 엑셀 파싱)
  print('\n🔄 [2/2] 학교 게시판에서 석식을 가져오는 중...');
  String dinnerMenu = '';
  
  try {
    final yearMonth = DateFormat('yyyyMM').format(targetDate);
    final saveDirectory = Directory('${Directory.current.path}/dinnerxlsx');
    final savePath = '${saveDirectory.path}/$yearMonth.xlsx';

    // 엑셀 다운로드 (스마트 캐싱 적용)
    if (!File(savePath).existsSync()) {
      if (!saveDirectory.existsSync()) saveDirectory.createSync(recursive: true);
      
      // targetDate 기준으로 해당 월의 엑셀 파일을 찾습니다.
      String? postUrl = await SchoolBoardScraper.findThisMonthExcelPostUrl(targetDate);
      if (postUrl != null) {
        String? savedPath = await SchoolBoardScraper.downloadDinnerExcel(postUrl, savePath);
        if (savedPath == null) throw Exception('엑셀 다운로드에 실패했습니다.');
      } else {
        throw Exception('해당 월의 석식 게시글을 찾을 수 없습니다.');
      }
    }

    // 다운받은 엑셀 파일에서 파이썬 엔진을 이용해 '일(day)'에 해당하는 반찬 추출
    dinnerMenu = await ExcelParser.getDinnerMenu(savePath, targetDate.day);
    
    // 영양정보 및 불필요한 텍스트 제거
    if (dinnerMenu.contains('* 에너지')) {
      dinnerMenu = dinnerMenu.split('* 에너지')[0].trim();
    }
    if (dinnerMenu.contains('*에너지')) {
      dinnerMenu = dinnerMenu.split('*에너지')[0].trim();
    }
    if (dinnerMenu.contains('석식정보없음') || dinnerMenu.isEmpty) {
      dinnerMenu = '오늘은 석식이 없습니다.';
    }
    
  } catch (e) {
    dinnerMenu = '오늘은 석식이 없습니다.';
  }

  // [4] 최종 결과 출력 및 JSON 저장
  print('\n=====================================');
  print('🍽️ ${targetDate.day}일 급식 메뉴 통합본 🍽️');
  print('=====================================');
  print('[ ☀️ 중식 ]\n$lunchMenu\n-------------------------------------');
  print('[ 🌙 석식 ]\n$dinnerMenu\n=====================================');

  // 위젯 렌더링(Test)에서 사용할 수 있도록 데이터를 JSON 파일로 저장합니다.
  final mealData = {
    'dateString': dateString,
    'lunchMenu': lunchMenu,
    'dinnerMenu': dinnerMenu,
  };
  
  final jsonFile = File(jsonPath);
  await jsonFile.writeAsString(jsonEncode(mealData));
  print('✅ 식단 데이터가 $jsonPath 에 저장되었습니다.');
}