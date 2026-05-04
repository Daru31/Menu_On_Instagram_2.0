import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:meal_project/api/neis_api.dart';
import 'package:meal_project/scraper/school_board.dart';
import 'package:meal_project/parser/excel_parser.dart';

void main() async {
  // [1] 날짜 설정
  // 💡 실제 서버(GitHub Actions)에서 매일 자동으로 돌릴 때는 아래 주석을 풀고 사용하세요!
  // final targetDate = DateTime.now(); 
  
  // 💡 지금은 확실하게 데이터가 있는 '6일'을 테스트하기 위해 날짜를 고정해두었습니다.
  final targetDate = DateTime(2026, 5, 6); 

  final dateString = DateFormat('yyyy년 MM월 dd일').format(targetDate);

  print('=====================================');
  print('🏫 통합 급식 수집 시스템 (중식 & 석식)');
  print('📅 타겟 날짜: $dateString');
  print('=====================================\n');

  // [2] 중식 수집 (나이스 API)
  print('🔄 [1/2] 나이스 API에서 중식을 가져오는 중...');
  String lunchMenu = await NeisApi.fetchLunch(targetDate);

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
    
  } catch (e) {
    dinnerMenu = '석식 정보를 가져오지 못했습니다.\n($e)';
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
  
  final jsonFile = File('meal_data.json');
  await jsonFile.writeAsString(jsonEncode(mealData));
  print('✅ 식단 데이터가 meal_data.json에 저장되었습니다.');
}
