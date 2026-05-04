import 'dart:io';

class ExcelParser {
  /// 파이썬 스크립트를 호출하여 엑셀 파일에서 특정 날짜의 석식 메뉴를 추출합니다.
  static Future<String> getDinnerMenu(String excelFilePath, int day) async {
    try {
      // 1. Python 스크립트 실행 (인자로 엑셀 파일 경로와 찾을 '일(day)'을 넘겨줍니다)
      final result = await Process.run(
        'python', 
        ['parse_excel.py', excelFilePath, day.toString()],
        // 한글 깨짐 방지를 위해 인코딩 명시 (윈도우 환경 대응)
        stdoutEncoding: systemEncoding, 
        stderrEncoding: systemEncoding,
      );

      if (result.exitCode == 0) {
        String output = result.stdout.toString().trim();
        if (output.isEmpty || output.contains('Menu not found')) {
           return '오늘 석식 정보가 엑셀 파일에 없습니다.';
        }
        return output;
      } else {
        print('Python 에러: ${result.stderr}');
        return '엑셀 파싱 실패 (Python 오류)';
      }
    } catch (e) {
      return '파싱 스크립트 실행 중 오류 발생: $e';
    }
  }
}