import 'package:meal_project/scraper/school_board.dart';

void main() async {
  print('=====================================');
  print('🔍 울산고 게시판 탐색 시작...');
  print('=====================================\n');
  
  String? postUrl = await SchoolBoardScraper.findThisMonthExcelPostUrl();
  
  if (postUrl != null) {
    print('✅ 석식 게시글 링크를 찾았습니다!');
    print('🔗 접속 링크: $postUrl');
  } else {
    print('❌ 게시글을 찾지 못했습니다.');
    print('   (학교 홈페이지 HTML 구조가 코드와 다르거나, 아직 이번 달 글이 안 올라왔을 수 있습니다.)');
  }
}
