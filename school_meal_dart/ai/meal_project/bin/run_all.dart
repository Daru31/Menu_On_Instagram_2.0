import 'dart:io';

void main() async {
  print('=====================================');
  print('🚀 통합 파이프라인 실행 시작');
  print('=====================================\n');

  print('🚀 [STEP 1] 급식 데이터 수집 스크립트 실행 중...');
  var fetchResult = await Process.run('dart', ['bin/daily_meal.dart'], runInShell: true);
  stdout.write(fetchResult.stdout);
  if (fetchResult.stderr.toString().isNotEmpty) {
    stderr.write(fetchResult.stderr);
  }

  if (fetchResult.exitCode != 0) {
    print('❌ 데이터 수집 중 오류가 발생하여 종료합니다.');
    exit(1);
  }

  print('\n🚀 [STEP 2] 이미지 렌더링 및 캡처 실행 중...');
  print('💡 (백그라운드에서 Flutter 앱이 잠시 켜졌다 닫힙니다)');
  var renderResult = await Process.run('flutter', ['run', '-d', 'windows'], runInShell: true);
  stdout.write(renderResult.stdout);
  if (renderResult.stderr.toString().isNotEmpty) {
    stderr.write(renderResult.stderr);
  }

  if (renderResult.exitCode != 0) {
    print('❌ 이미지 렌더링 중 오류가 발생하여 종료합니다.');
    exit(1);
  }

  print('\n🚀 [STEP 3] 인스타그램 업로드 스크립트 실행 중...');
  var uploadResult = await Process.run('python', ['upload_to_insta.py'], runInShell: true);
  stdout.write(uploadResult.stdout);
  if (uploadResult.stderr.toString().isNotEmpty) {
    stderr.write(uploadResult.stderr);
  }

  print('\n=====================================');
  print('✅ 모든 작업(수집 -> 렌더링 -> 업로드)이 성공적으로 완료되었습니다!');
  print('📂 생성된 이미지 확인: images/ 폴더');
  print('=====================================');
}