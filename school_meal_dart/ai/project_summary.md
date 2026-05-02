# School Meal 프로젝트 요약

현재 `C:\flutter_project\school_meal` 디렉토리에 있는 프로젝트들의 구조와 기능을 분석한 요약입니다.

## 1. Menu_On_Instagram_2.0 (인스타그램 자동 업로드 스크립트)
이 디렉토리는 나이스(NEIS) API를 통해 급식 정보를 가져와 이미지로 변환한 후, 인스타그램 스토리에 자동 업로드하는 기능을 수행합니다.

* **`main.php`**: 
  * 웹 서버 환경에서 동작하며, 나이스 오픈 API를 호출하여 특정 날짜의 울산고등학교 급식 정보(중식, 석식)를 가져옵니다.
  * API 호출 결과를 `DB/YYYYMMDD.txt` 형식으로 로컬에 캐싱하여 API 호출 횟수를 줄이고 속도를 높입니다.
  * 가져온 급식 정보를 보기 좋게 HTML/CSS로 렌더링합니다. 모바일 화면 사이즈(510x1080)에 맞춰져 있으며, 울산고 학생회 봉사부 명의로 제공된다는 문구가 포함되어 있습니다.
* **`main.py`**:
  * Python 자동화 스크립트로 두 가지 주요 역할을 수행합니다.
  * **웹 스크린샷 (`web_screenshot`)**: Selenium(Firefox headless 모드)을 사용하여 `main.php` 호스팅 주소에 접속해 렌더링된 급식 정보 페이지를 `screenshot.png` 파일로 캡처합니다.
  * **인스타그램 업로드 (`login_upload`)**: `instagrapi` 라이브러리를 사용하여 지정된 인스타그램 계정에 로그인한 뒤, 캡처된 `screenshot.png` 이미지를 인스타그램 스토리로 업로드합니다.
  * `session.json`을 통해 로그인 세션을 관리합니다.
* **기타 파일**: `requirements.txt` (Python 의존성), `setup.py`

## 2. school_meal_dart / meal_project (Flutter 앱)
이 디렉토리는 기존 웹/스크립트 기반의 서비스를 모바일 앱이나 웹 앱 형태로 확장하기 위해 생성된 Dart 기반의 Flutter 프로젝트로 보입니다.

* **초기 단계**: 
  * 현재 `lib/main.dart`를 확인한 결과, Flutter 프로젝트 생성 시 기본으로 제공되는 Counter 앱(버튼을 누르면 숫자가 올라가는 데모 앱) 코드가 그대로 유지되어 있습니다.
  * 앱 이름은 `meal_project`로 설정되어 있으며, Android, iOS, macOS, Windows, Linux, Web 등 다양한 플랫폼을 위한 빌드 설정이 포함되어 있습니다.
  * 아직 나이스 API 연동이나 급식 정보를 보여주는 UI 등 핵심 비즈니스 로직은 구현되지 않은 초기 설정 상태입니다.

---
**총평**: 기존 버전(`Menu_On_Instagram_2.0`)은 PHP와 Python을 결합하여 급식 정보를 인스타그램에 자동 업로드하는 시스템으로 완성되어 작동하는 형태입니다. 내부의 `school_meal_dart` 폴더에 있는 `meal_project`는 앞으로 이를 스마트폰 앱(Flutter)으로 새롭게 개발하거나 기능을 확장하기 위해 만들어둔 초기 프로젝트로 파악됩니다.
