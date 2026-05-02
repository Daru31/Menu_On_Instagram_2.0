# 구현 가이드 및 로드맵 (Implementation Guide)

본 문서는 `tech_spec.md`에서 정의한 구조를 실제로 구현하기 위한 단계별 작업 지침입니다.

## 1단계: Flutter 백그라운드 캡처 로직 구현 (이쁜 위젯 만들기)
Flutter의 장점인 UI 위젯을 적극 활용하여 디자인합니다.

1. `pubspec.yaml`에 필요한 패키지 추가: `http`, `screenshot`
2. `test/` 폴더 내에 이미지 생성 전용 테스트 파일 생성.
3. 코드 예시 (실제로는 테스트 환경에서 동작하게 래핑됨):
   ```dart
   // 모바일 앱 만들 때처럼 똑같이 위젯을 디자인합니다!
   Widget mealCard = Container(
     width: 1080,
     height: 1080,
     decoration: BoxDecoration(
       gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
       borderRadius: BorderRadius.circular(30),
       boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
     ),
     child: Center(
       child: Text(
         '오늘의 급식\n돈까스, 샐러드...',
         style: TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold),
       ),
     ),
   );
   
   // screenshot 패키지로 위젯을 찰칵!
   final imageBytes = await screenshotController.captureFromWidget(mealCard);
   File('meal_today.png').writeAsBytesSync(imageBytes);
   ```

## 2단계: 공식 Instagram Graph API 연동 준비 (계정 정지 방지)
`instagrapi` 같은 비공식 봇 라이브러리 대신, 정지 위험이 없는 메타(Meta) 공식 API를 세팅합니다.

1. **사전 준비 (사용자 직접 수행)**:
   * 인스타그램 계정을 '프로페셔널 계정'으로 전환.
   * 페이스북 페이지를 하나 만들고 인스타그램 계정과 연결.
   * Meta for Developers(개발자 센터)에서 앱을 만들고 `Page Access Token`과 `Instagram Account ID` 발급.
2. 루트 디렉토리에 `upload_to_insta.py` 생성.
3. Python `requests` 라이브러리를 사용하여 공식 API에 이미지 URL과 캡션을 전송하는 로직 작성. (GitHub Actions에서는 이미지를 호스팅 서비스인 Imgur 등에 임시로 올린 뒤 공식 API로 전송하는 방식을 주로 씁니다.)

## 3단계: GitHub Actions 워크플로우 세팅
`.github/workflows/daily_upload.yml` 파일을 작성하여 전체 과정을 자동화합니다.

```yaml
name: Daily School Meal Instagram Upload

on:
  schedule:
    - cron: '0 22 * * *'
  workflow_dispatch:

jobs:
  run_meal_bot:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'

      - name: Setup XVFB (Virtual Display)
        run: sudo apt-get install -y xvfb

      - name: Generate Beautiful Meal Image via Flutter
        run: |
          xvfb-run --auto-servernum flutter test test/generate_meal_image_test.dart

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install Python Dependencies
        run: pip install requests

      - name: Upload to Instagram via Official Graph API
        env:
          GRAPH_API_TOKEN: ${{ secrets.GRAPH_API_TOKEN }}
          IG_USER_ID: ${{ secrets.IG_USER_ID }}
        run: python upload_to_insta.py
```
