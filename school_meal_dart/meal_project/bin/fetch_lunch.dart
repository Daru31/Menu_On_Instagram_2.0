import 'package:meal_project/api/neis_api.dart';
import 'package:intl/intl.dart';

void main() async {
  print('=====================================');
  print('🏫 울산고등학교 중식 메뉴 가져오기 테스트 🏫');
  print('=====================================\n');

  // 과거의 평일 날짜 (2024년 5월 2일 목요일)로 테스트하여 확실히 데이터가 나오는지 확인합니다.
  final today = DateTime(2024, 5, 2);
  final formattedDate = DateFormat('yyyy년 MM월 dd일').format(today);
  
  print('[$formattedDate] 데이터 로딩 중...');

  // NeisApi를 통해 중식 정보 호출
  String lunchMenu = await NeisApi.fetchLunch(today);

  print('\n🍽️ 오늘의 중식 메뉴:');
  print('-------------------------------------');
  print(lunchMenu);
  print('-------------------------------------');
  print('\n테스트가 완료되었습니다.');
}
