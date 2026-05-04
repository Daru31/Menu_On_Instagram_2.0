import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NeisApi {
  // 울산광역시교육청 코드 (H10) 및 울산고등학교 코드 (7480035)
  static const String ATPT_OFCDC_SC_CODE = 'H10';
  static const String SD_SCHUL_CODE = '7480035';
  
  static const String apiKey = '8800eb07d6264088b1976ba95b4ccfa1'; 

  /// 특정 날짜의 중식 데이터를 가져옵니다. (날짜 생략 시 오늘 날짜)
  static Future<String> fetchLunch([DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    // API에서 요구하는 YYYYMMDD 형식으로 변환
    final dateString = DateFormat('yyyyMMdd').format(targetDate);
    
    // MMEAL_SC_CODE=2 는 중식을 의미합니다.
    String baseUrl = 'https://open.neis.go.kr/hub/mealServiceDietInfo'
        '?Type=json'
        '&pIndex=1'
        '&pSize=5'
        '&ATPT_OFCDC_SC_CODE=$ATPT_OFCDC_SC_CODE'
        '&SD_SCHUL_CODE=$SD_SCHUL_CODE'
        '&MLSV_YMD=$dateString'
        '&MMEAL_SC_CODE=2'; 

    if (apiKey.isNotEmpty) {
      baseUrl += '&KEY=$apiKey';
    }

    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        // 에러나 데이터가 없는 경우 처리
        if (decodedData.containsKey('RESULT')) {
          final resultCode = decodedData['RESULT']['CODE'];
          final resultMessage = decodedData['RESULT']['MESSAGE'];
          return '데이터를 불러오지 못했습니다. ($resultCode: $resultMessage)';
        }

        // 정상적으로 데이터를 가져온 경우
        if (decodedData.containsKey('mealServiceDietInfo')) {
          final mealInfoList = decodedData['mealServiceDietInfo'];
          
          // 'row' 키를 가진 배열 찾기
          for (var item in mealInfoList) {
            if (item.containsKey('row')) {
              final rows = item['row'];
              if (rows.isNotEmpty) {
                // 메뉴 추출
                String rawDishName = rows[0]['DDISH_NM'];
                
                // 데이터에 포함된 알레르기 정보(예: (1.2.3.))와 불필요한 줄바꿈 제거
                String cleanedDishName = rawDishName.replaceAll(RegExp(r'\([^)]*\)'), ''); // 괄호와 그 안의 내용 제거
                cleanedDishName = cleanedDishName.replaceAll('<br/>', '\n'); // HTML 줄바꿈을 일반 줄바꿈으로 변경
                
                // 추가적인 정리: 각 줄 앞뒤 공백 제거
                cleanedDishName = cleanedDishName.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).join('\n');

                return cleanedDishName;
              }
            }
          }
        }
        return '오늘 중식 정보가 없습니다.';
      } else {
        return 'API 호출 실패: 상태 코드 ${response.statusCode}';
      }
    } catch (e) {
      return 'API 호출 중 오류 발생: $e';
    }
  }
}
