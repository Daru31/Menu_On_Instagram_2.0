import 'dart:io';
import 'package:intl/intl.dart';
import 'package:meal_project/scraper/school_board.dart';
import 'package:meal_project/parser/excel_parser.dart';

void main() async {
  print('=====================================');
  print('🔍 전체 과정 통합 테스트 (크롤링 -> 다운로드 -> 엑셀 파싱)');
  print('=====================================\n');
  
  try {
    final now = DateTime.now();
    final yearMonth = DateFormat('yyyyMM').format(now);
    final saveDirectory = Directory('${Directory.current.path}/dinnerxlsx');
    final savePath = '${saveDirectory.path}/$yearMonth.xlsx';

    // 1. 캐싱 & 다운로드 로직
    if (!File(savePath).existsSync()) {
      print('⚠️ 이번 달 엑셀 파일이 없습니다. 크롤링을 시작합니다...');
      if (!saveDirectory.existsSync()) saveDirectory.createSync(recursive: true);

      String? postUrl = await SchoolBoardScraper.findThisMonthExcelPostUrl();
      if (postUrl != null) {
        String? savedFilePath = await SchoolBoardScraper.downloadDinnerExcel(postUrl, savePath);
        if (savedFilePath == null) throw Exception('엑셀 파일 다운로드 실패');
        print('🎉 엑셀 다운로드 성공!');
      } else {
        throw Exception('이번 달 게시글을 찾지 못했습니다.');
      }
    } else {
      print('✅ 엑셀 캐시 확인 완료 ($savePath)');
    }

    // 2. 엑셀 파싱 로직 (Python 연동)
    // 테스트: 엑셀 파일 안에 메뉴가 확실히 들어있을 법한 4일로 테스트합니다.
    int targetDay = 4; // 실제 구현시에는 now.day 를 사용합니다.
    print('\n🔄 Python 엔진을 호출하여 $targetDay일 석식 반찬을 추출합니다...');
    
    String dinnerMenu = await ExcelParser.getDinnerMenu(savePath, targetDay);
    
    print('\n🍽️ 파싱된 $targetDay일 석식 메뉴:');
    print('-------------------------------------');
    print(dinnerMenu);
    print('-------------------------------------');

  } catch (e) {
    print('\n[오류 발생] $e');
  }
}
