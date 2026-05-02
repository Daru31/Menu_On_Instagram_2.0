import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';

class SchoolBoardScraper {
  // 울산고등학교 급식 게시판 주소 (제목에 '석식'이 포함된 게시물 검색 결과 페이지)
  static const String boardUrl = 'https://school.use.go.kr/ulsan-hs-h/M01030701/list?s_field=title&s_word=%EC%84%9D%EC%8B%9D';

  /// 이번 달 석식 엑셀 파일이 있는 게시글 링크를 찾습니다.
  static Future<String?> findThisMonthExcelPostUrl() async {
    try {
      final response = await http.get(Uri.parse(boardUrl));
      
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.body);

        // 일반적인 나이스 학교 홈페이지 게시판 목록의 a 태그 찾기
        // (실제 홈페이지 구조에 따라 CSS 선택자는 수정될 수 있습니다)
        var titleElements = document.querySelectorAll('td.title a'); 
        if (titleElements.isEmpty) {
          // 간혹 title 클래스가 없거나 구조가 다를 수 있으므로 조금 넓게 찾아봅니다.
          titleElements = document.querySelectorAll('.board-list a');
        }
        if (titleElements.isEmpty) {
            titleElements = document.querySelectorAll('a'); // 너무 넓지만 일단 시도
        }

        // 테스트할 때는 이번 달을 기준으로 찾습니다 (예: '5월')
        String thisMonth = DateFormat('M월').format(DateTime.now());

        for (var element in titleElements) {
          String titleText = element.text;
          
          // '석식'이라는 단어와 이번 달 'M월'이 포함된 게시글 제목 찾기
          if (titleText.contains('석식') && titleText.contains(thisMonth)) {
            String? postLink = element.attributes['href'];
            if (postLink != null) {
              if (postLink.startsWith('/')) {
                return 'https://school.use.go.kr$postLink'; 
              } else {
                return postLink;
              }
            }
          }
        }
        
        // 만약 이번 달 게시글을 못 찾았으면, 제목에 '석식'만 들어간 가장 최근 게시글을 찾아봅니다 (테스트용)
        for (var element in titleElements) {
          String titleText = element.text;
          if (titleText.contains('석식')) {
             String? postLink = element.attributes['href'];
             if (postLink != null) {
                if (postLink.startsWith('/')) {
                  return 'https://school.use.go.kr$postLink'; 
                } else {
                  return postLink;
                }
             }
          }
        }

        return null;
      } else {
        print('게시판 접속 실패: 상태 코드 ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('크롤링 중 오류 발생: $e');
      return null;
    }
  }
}
