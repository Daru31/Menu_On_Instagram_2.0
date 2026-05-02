# 구현 가이드 및 로드맵 (Implementation Guide)

본 문서는 `tech_spec.md`에서 정의한 구조를 실제로 구현하기 위한 단계별 작업 지침입니다.

## 1단계: 중식(API) 및 석식(크롤링/엑셀) 데이터 수집 로직 구현

Dart를 활용하여 두 가지 방식의 데이터를 가져오는 스크립트를 작성합니다.

1. `pubspec.yaml` 패키지 추가: `http`, `html` (웹 스크래핑용), `excel` (엑셀 파일 파싱용), `path_provider`
2. **중식 로직**: NEIS API 호출 함수 작성
3. **석식 로직**:
   - 로컬 디렉토리에 이번 달 엑셀 파일(`2026_05_dinner.xlsx`)이 있는지 검사.
   - 없다면 `https://school.use.go.kr/ulsan-hs-h/M01030701/` 에 접속해 HTML 파싱 -> 최신 석식 게시글의 첨부파일 링크 추출 -> 다운로드하여 로컬 저장.
   - 엑셀 파일을 열어 오늘 날짜 열/행을 매칭하여 메뉴 텍스트 추출.

## 2단계: Flutter 백그라운드 캡처 로직 구현 (이쁜 위젯 만들기)

Flutter의 장점인 UI 위젯을 적극 활용하여 디자인합니다.

1. `pubspec.yaml` 패키지 추가: `screenshot`
2. `test/generate_meal_image_test.dart` 파일 생성:

   ```dart
   // 인스타 스토리 사이즈(1080x1920)에 맞춘 위젯 디자인
   Widget mealCard = Container(
     width: 1080,
     height: 1920,
     decoration: BoxDecoration( /* 이쁜 배경 및 그라데이션 */ ),
     child: Column(
       children: [
         Text('오늘의 중식: $lunchData'),
         Text('오늘의 석식: $dinnerData'),
       ],
     ),
   );

   // 위젯을 이미지(png)로 저장
   final imageBytes = await screenshotController.captureFromWidget(mealCard);
   File('meal_today.png').writeAsBytesSync(imageBytes);
   ```

## 3단계: 음악 추가 (FFmpeg 합성) 및 Python 업로드 스크립트

인스타그램 공식 API는 앱 내부의 '음악 스티커' 기능을 외부 API로 제공하지 않습니다. 따라서 음악을 넣으려면 **이미지와 MP3를 합쳐서 비디오 파일(MP4)로 만든 뒤 비디오 스토리로 업로드**해야 합니다.

1. 프로젝트 내에 배경음악으로 쓸 `bgm.mp3` 파일을 미리 준비해 둡니다. (저작권 없는 음악 혹은 짧은 음원)
2. 업로드 스크립트(`upload_to_insta.py`)를 작성하여, 이미지(또는 영상)를 공식 Graph API를 통해 업로드하도록 구성.

## 4단계: GitHub Actions 워크플로우 세팅

전체 파이프라인을 자동화하는 `.github/workflows/daily_upload.yml` 작성.

```yaml
name: Daily School Meal Instagram Upload

on:
  schedule:
    - cron: "0 22 * * *" # 한국 시간 아침 7시
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
          channel: "stable"

      - name: Setup XVFB and FFmpeg
        run: |
          sudo apt-get update
          sudo apt-get install -y xvfb ffmpeg

      - name: Generate Beautiful Meal Image via Flutter Test
        run: xvfb-run --auto-servernum flutter test test/generate_meal_image_test.dart

      - name: Add Music to Image (Create MP4 Video)
        run: |
          # 이미지와 mp3를 합쳐서 15초짜리 비디오를 생성하는 FFmpeg 명령어
          ffmpeg -loop 1 -i meal_today.png -i assets/bgm.mp3 -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -t 15 -shortest meal_today.mp4

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.10"

      - name: Install Python Dependencies
        run: pip install requests

      - name: Upload to Instagram via Official Graph API
        env:
          GRAPH_API_TOKEN: ${{ secrets.GRAPH_API_TOKEN }}
          IG_USER_ID: ${{ secrets.IG_USER_ID }}
        run: python upload_to_insta.py --file meal_today.mp4 --type video
```
