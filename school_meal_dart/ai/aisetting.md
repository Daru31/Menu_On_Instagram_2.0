# 🚨 Gemini CLI 중요 지침 및 프로젝트 상태 보고서 (aisetting)

## ⚠️ 핵심 보안 및 접근 규칙 (절대 준수)
1. **작기 권한 제한**: 모든 **파일 생성, 수정, 삭제(Write)** 행위는 오직 `C:\flutter_project\school_meal\Menu_On_Instagram_2.0\school_meal_dart\ai\` 폴더 내부에서만 허용됩니다.
2. **읽기 권한**: `ai` 폴더 밖의 메인 프로젝트 폴더는 오직 **내용 확인(Read-only)** 목적으로만 접근할 수 있습니다. 절대로 메인 폴더의 파일을 직접 수정하거나 명령어를 실행해서는 안 됩니다.
3. **명령어 실행**: 모든 터미널 명령어(Flutter, Dart, Python 등)는 `ai/meal_project` 디렉토리 내에서만 수행합니다.

---

## 📅 프로젝트 진행 상태 요약 (2026-05-02 기준)

### 1. 완료된 작업 (Milestones)
*   ✅ **데이터 수집 파이프라인 구축**:
    *   `NeisApi`: 나이스 오픈 API를 통한 울산고 중식 데이터 수집 완료.
    *   `SchoolBoardScraper`: 울산고 홈페이지 게시판 크롤링을 통한 월간 석식 엑셀 다운로드 완료.
    *   **스마트 캐싱**: `YYYYMM.xlsx` 형식으로 폴더(`dinnerxlsx`)에 자동 저장 및 중복 다운로드 방지.
*   ✅ **엑셀 데이터 추출 엔진 (하이브리드 방식)**:
    *   Dart 라이브러리 한계 극복을 위해 Python(`pandas`, `openpyxl`)을 부하 프로세스로 활용.
    *   `parse_excel.py`: 달력 형태의 엑셀에서 날짜를 찾아 메뉴를 정확히 뽑아내는 로직 완성.
*   ✅ **UI 디자인 및 이미지 렌더링**:
    *   `MealCard`: 인스타 스토리 규격(1080x1920)의 세련된 위젯 디자인 완성.
    *   `render_image.dart` / `main.dart`: `screenshot` 패키지를 이용해 위젯을 `meal_today.png` 이미지로 저장 성공.

### 2. 현재 시스템 아키텍처
1.  **Dart (`daily_meal.dart`)**: 전체 흐름 제어, API 호출, 웹 크롤링, 결과 JSON 저장.
2.  **Python (`parse_excel.py`)**: 복잡한 엑셀 파일 정밀 분석 및 텍스트 추출.
3.  **Flutter (`main.dart`)**: `meal_data.json`을 읽어 예쁜 위젯을 그리고 PNG로 캡처.

### 3. 남은 작업 (Next Steps)
*   🔲 **인스타그램 업로드**: 완성된 `meal_today.png`를 인스타그램 공식 Graph API를 통해 자동으로 게시하는 Python 스크립트 작성.
*   🔲 **GitHub Actions 통합**: 이 모든 파이프라인을 매일 아침 자동으로 실행할 워크플로우 파일 완성.

---

## 📂 주요 파일 위치 정보
*   **API/스크레이퍼**: `ai/meal_project/lib/api/`, `ai/meal_project/lib/scraper/`
*   **UI 위젯**: `ai/meal_project/lib/widgets/meal_card.dart`
*   **데이터 추출 (Python)**: `ai/meal_project/parse_excel.py`
*   **통합 실행 스크립트**: `ai/meal_project/bin/daily_meal.dart`
*   **이미지 렌더러**: `ai/meal_project/lib/main.dart` (또는 `bin/render_image.dart`)
*   **캐시 폴더**: `ai/meal_project/dinnerxlsx/`
