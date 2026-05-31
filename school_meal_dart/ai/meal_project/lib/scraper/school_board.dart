import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';

class SchoolBoardScraper {
  static const String baseUrl = 'https://school.use.go.kr';
  // 제목에 '석식'이 포함된 게시물 검색 결과 페이지
  static const String boardUrl = '$baseUrl/ulsan-hs-h/M01030701/list?s_field=title&s_word=%EC%84%9D%EC%8B%9D';

  /// 1. 특정 날짜(월)의 석식 엑셀 파일이 있는 게시글 링크를 찾습니다.
  static Future<String?> findThisMonthExcelPostUrl([DateTime? date]) async {
    try {
      print('🌐 [로그] 학교 게시판 접속 시도: $boardUrl');
      final response = await http.get(Uri.parse(boardUrl)).timeout(const Duration(seconds: 15));
      print('🌐 [로그] 학교 게시판 응답 코드: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ [에러] 게시판 접속 실패: 상태 코드 ${response.statusCode}');
        print('🔍 [디버그] 응답 본문 일부: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
        return null;
      }

      var document = html_parser.parse(response.body);

      // 최적화 1: 다중 CSS 선택자로 한 번에 필요한 <a> 태그들만 추출
      var titleElements = document.querySelectorAll('td.title a, .board-list a'); 
      if (titleElements.isEmpty) {
        titleElements = document.querySelectorAll('a'); // 최후의 보루
      }

      final targetDate = date ?? DateTime.now();
      String thisMonth = DateFormat('M월').format(targetDate);
      String shortYear = DateFormat('yy년').format(targetDate);  // 26년 (2026년도 포함됨)

      // 최적화 2 & 정확도 향상: 
      // 1순위: 'YY년'(2026년도 자연스럽게 포함됨)과 'M월'이 모두 포함된 링크들 먼저 필터링
      var matchingLinks = titleElements
          .where((e) => e.text.contains(shortYear) && e.text.contains(thisMonth))
          .map((e) => e.attributes['href'])
          .where((href) => href != null && href.isNotEmpty)
          .map((href) => href!.startsWith('/') ? '$baseUrl$href' : href)
          .toList();
          
      // 2순위: 1순위 조건에 맞는 게시글이 없다면, 'M월'만 포함된 링크로 재검색 (Fallback)
      if (matchingLinks.isEmpty) {
        matchingLinks = titleElements
            .where((e) => e.text.contains(thisMonth))
            .map((e) => e.attributes['href'])
            .where((href) => href != null && href.isNotEmpty)
            .map((href) => href!.startsWith('/') ? '$baseUrl$href' : href)
            .toList();
      }

      // 검색 결과에 따른 분기 처리
      if (matchingLinks.length > 1) {
        // 동일한 달의 게시글이 2개 이상일 경우
        // 실제 구현 시 여기서 디스코드/이메일 알림 API를 호출합니다.
        print('🚨 [긴급 알림] 이번 달($thisMonth) 석식 게시글이 ${matchingLinks.length}개 발견되었습니다. 가장 최근 글로 진행합니다.');
        return matchingLinks.first; 
      } else if (matchingLinks.length == 1) {
        return matchingLinks.first; 
      }

      // 이번 달 게시글이 없다면 최상단(가장 최근) 링크 반환
      if (titleElements.isNotEmpty) {
        String? firstLink = titleElements.first.attributes['href'];
        if (firstLink != null) {
          return firstLink.startsWith('/') ? '$baseUrl$firstLink' : firstLink;
        }
      }
      return null;
    } catch (e) {
      print('❌ [에러] 게시글 탐색 중 네트워크/파싱 오류 발생: $e');
      // 여러 개 발견된 Exception은 상위로 던져서 알림을 발생시키도록 합니다.
      if (e.toString().contains('알림:')) rethrow; 
      return null;
    }
  }

  /// 2. 찾은 게시글 안에서 '.xlsx' 엑셀 파일을 찾아 로컬에 다운로드합니다.
  static Future<String?> downloadDinnerExcel(String postUrl, String savePath) async {
    try {
      print('🌐 [로그] 게시글 세부 페이지 접속 시도: $postUrl');
      final response = await http.get(Uri.parse(postUrl)).timeout(const Duration(seconds: 15));
      print('🌐 [로그] 게시글 세부 페이지 응답 코드: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('❌ [에러] 게시글 접속 실패: 상태 코드 ${response.statusCode}');
        print('🔍 [디버그] 응답 본문 일부: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
        return null;
      }

      var document = html_parser.parse(response.body);

      // 첨부파일 링크 찾기 (보통 'file' 클래스나 직접 확장자를 찾음)
      var fileLinks = document.querySelectorAll('a');
      String? excelDownloadUrl;

      for (var link in fileLinks) {
        String text = link.text.toLowerCase();
        String? href = link.attributes['href'];
        
        // 텍스트에 .xlsx 가 포함되어 있거나, 다운로드 링크 자체에 포함된 경우
        if ((text.contains('.xlsx') || text.contains('.xls')) && href != null) {
          excelDownloadUrl = href.startsWith('/') ? '$baseUrl$href' : href;
          break; // 첫 번째 엑셀 파일을 찾으면 중단
        }
      }

      if (excelDownloadUrl == null) {
        print('❌ [에러] 엑셀 첨부파일을 찾을 수 없습니다.');
        return null;
      }

      print('🌐 [로그] 엑셀 다운로드 링크 발견: $excelDownloadUrl\n🌐 [로그] 엑셀 다운로드 시도 중...');
      
      // 실제 파일 다운로드 수행
      final fileResponse = await http.get(Uri.parse(excelDownloadUrl)).timeout(const Duration(seconds: 30));
      print('🌐 [로그] 엑셀 다운로드 응답 코드: ${fileResponse.statusCode}');
      
      if (fileResponse.statusCode == 200) {
        File file = File(savePath);
        await file.writeAsBytes(fileResponse.bodyBytes);
        return savePath;
      } else {
        print('❌ [에러] 파일 다운로드 실패: 상태 코드 ${fileResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ [에러] 다운로드 중 네트워크 오류 발생: $e');
      return null;
    }
  }
}
