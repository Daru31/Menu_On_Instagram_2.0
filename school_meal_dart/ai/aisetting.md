# 🚨 Gemini CLI 중요 지침 및 프로젝트 상태 보고서 (aisetting)

## ⚠️ 핵심 보안 및 접근 규칙 (절대 준수)
1. **작기 권한 제한**: 모든 **파일 생성, 수정, 삭제(Write)** 행위는 오직 `C:\flutter_project\school_meal\Menu_On_Instagram_2.0\school_meal_dart\ai\` 폴더 내부에서만 허용됩니다.
2. **읽기 권한**: `ai` 폴더 밖의 메인 프로젝트 폴더는 오직 **내용 확인(Read-only)** 목적으로만 접근할 수 있습니다. 절대로 메인 폴더의 파일을 직접 수정하거나 명령어를 실행해서는 안 됩니다.
3. **명령어 실행**: 모든 터미널 명령어(Flutter, Dart, Python 등)는 `ai/meal_project` 디렉토리 내에서만 수행합니다.

---

## 📅 프로젝트 진행 상태 요약 (2026-05-04 업데이트 기준)

### 1. 완료된 작업 (Milestones)
*   ✅ **데이터 수집 파이프라인 구축**:
    *   `NeisApi`: 나이스 오픈 API를 통한 울산고 중식 데이터 수집 완료.
    *   `SchoolBoardScraper`: 울산고 홈페이지 게시판 크롤링을 통한 월간 석식 엑셀 다운로드 완료.
    *   **스마트 캐싱**: `YYYYMM.xlsx` 형식으로 폴더(`dinnerxlsx`)에 자동 저장 및 중복 다운로드 방지.
*   ✅ **엑셀 데이터 추출 엔진 (하이브리드 방식)**:
    *   Dart 라이브러리 한계 극복을 위해 Python(`pandas`, `openpyxl`)을 부하 프로세스로 활용.
    *   `parse_excel.py`: 달력 형태의 엑셀에서 날짜를 찾아 메뉴를 정확히 뽑아내는 로직 완성.
*   ✅ **UI 디자인 및 렌더링 방식 고도화**:
    *   기존 한 장짜리 이미지(`meal_today.png`)에서 **중식/석식 개별 이미지 2장(`YYYYMMDD_lunch.png`, `YYYYMMDD_dinner.png`)으로 분리**.
    *   중식(구름/햇살), 석식(별/달) 테마 배경 적용 및 텍스트 렌더링 간격/크기 조절.
    *   리눅스 렌더링 환경을 대비해 컬러 이모지(`Noto Color Emoji`, `Apple Color Emoji`) 폴백 폰트 세팅.
    *   사용되지 않는 테스트 파일(`render_image.dart`, `widget_test.dart`) 삭제.
*   ✅ **인스타그램 자동 업로드 파이썬 봇 연동**:
    *   `instagrapi` 라이브러리를 활용한 `upload_to_insta.py` 작성.
    *   **보안 강화**: 하드코딩된 아이디/비밀번호 제거 후 `IG_USERNAME`, `IG_PASSWORD` 환경변수 처리.
    *   **우회 처리**: 2FA/해외 로그인 차단 방지를 위해 로컬에서 `session.json`(`IG_SESSION`) 발급 방식 도입.
    *   **오류 패치**: `instagrapi`의 PNG Payload 버그를 우회하기 위해 PIL 라이브러리로 JPG 변환 후 업로드.
*   ✅ **GitHub Actions 파이프라인 완벽 구축**:
    *   리눅스 가상 디스플레이(`xvfb`) 및 C++/GTK 필수 빌드 라이브러리 연동 완료.
    *   한글 폰트(`fonts-nanum`) 및 컬러 이모지(`fonts-noto-color-emoji`) 설치 옵션 추가 완료.
    *   월~금 평일에만 동작하도록 UTC 시차를 고려한 Cron 스케줄러(`1 15 * * 0-4`) 설정.

### 2. 현재 시스템 아키텍처 (Run All)
1.  **Dart (`daily_meal.dart`)**: API 및 크롤링으로 식단 추출, 공휴일 예외 처리 후 `json_data` 폴더에 날짜별 JSON 저장.
2.  **Flutter (`main.dart`)**: 가장 최신 JSON 데이터를 불러와 `MealCard` 위젯을 그리고 `images/` 폴더에 JPG(PNG) 캡처.
3.  **Python (`upload_to_insta.py`)**: `instagrapi`와 깃허브 `Secrets`를 이용해 안전하게 인스타 스토리에 2장 순차 업로드.
4.  **GitHub Actions (`daily_upload.yml`)**: 매일 밤 12시 1분(KST 기준 평일) 위 3단계를 자동으로 묶어서 실행.

### 3. 남은 작업 및 주의사항 (Next Steps)
*   **완벽 자동화 유지**: 코드 상의 개인정보(세션, 계정)는 이미 완벽히 삭제되었으므로, 앞으로도 절대 하드코딩하지 말고 GitHub Secrets만 사용할 것.
*   **모니터링**: 깃허브 Actions 탭을 통해 매일 업로드가 잘 되고 있는지 간헐적으로 체크할 것.

---

## 📂 주요 파일 위치 정보
*   **통합 파이프라인(Run All)**: `ai/meal_project/bin/run_all.dart`
*   **데이터 추출 (Dart & Python)**: `ai/meal_project/bin/daily_meal.dart`, `parse_excel.py`
*   **UI 위젯 & 이미지 렌더러**: `ai/meal_project/lib/widgets/meal_card.dart`, `lib/main.dart`
*   **인스타그램 업로드 (Python)**: `ai/meal_project/upload_to_insta.py`
*   **로컬 세션 발급기**: `ai/meal_project/login_only.py`
*   **GitHub Actions 스케줄러**: `.github/workflows/daily_upload.yml`
*   **데이터 캐시 폴더**: `json_data/` (식단 JSON), `dinnerxlsx/` (석식 엑셀), `images/` (렌더링 결과물)