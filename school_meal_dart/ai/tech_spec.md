# 프로젝트 기술 명세서 (Technical Specification)

## 1. 프로젝트 개요
* **프로젝트명**: School Meal Auto-Uploader (Flutter & GitHub Actions 기반)
* **목적**: 매일 정해진 시간에 나이스(NEIS) API로부터 학교 급식 정보를 수집하고, Flutter의 강력한 UI 렌더링 기능을 활용해 인스타그램 감성에 맞는 고품질 이미지로 변환한 뒤, 인스타그램 계정에 자동 업로드하는 시스템을 구축한다.
* **특징**: 로컬 PC나 별도의 서버 구동 없이, **GitHub Actions**의 스케줄러를 활용하여 100% 클라우드 환경에서 자동화(Serverless)로 동작한다.

## 2. 시스템 아키텍처 및 파이프라인
프로젝트는 크게 4단계 파이프라인으로 구성되어 GitHub Actions 환경에서 순차적으로 실행된다.

1. **데이터 수집 (Data Fetching)**: NEIS 오픈 API 호출을 통해 당일 급식 식단 추출
2. **UI 렌더링 (Headless Rendering)**: 가상 디스플레이 환경(XVFB)에서 **Flutter의 모든 UI 위젯(Container, Text, BoxDecoration, 그림자 효과 등)을 사용하여 예쁜 식단표 화면을 메모리 상에 구성**
3. **이미지 캡처 (Image Export)**: 디자인된 위젯 화면을 스크린샷 캡처하여 `.png` 형태의 고화질 이미지 파일로 저장
4. **인스타그램 업로드 (Auto Upload)**: **공식 Instagram Graph API**를 통해 정지 위험 없이 안전하게 캡처된 이미지를 인스타그램에 게시

## 3. 핵심 기술 스택
### 3.1. Flutter (Dart)
* **역할**: 데이터 수집 및 UI 디자인, 이미지 캡처
* **특징**: 일반 모바일 앱을 만들 때 쓰는 위젯 코드 그대로 사용하여 디자인. (배경 이미지, 그라데이션, 둥근 모서리 등 모두 적용 가능)
* **주요 패키지**:
  * `http` 또는 `dio`: NEIS API와의 네트워크 통신
  * `screenshot`: Flutter 위젯 트리를 그대로 캡처하여 이미지 파일로 변환

### 3.2. GitHub Actions
* **역할**: 크론(Cron) 기반의 매일 자동 실행 스케줄링 및 CI 환경 제공
* **환경**: `ubuntu-latest`
* **핵심 유틸리티**: `xvfb` (X Virtual Framebuffer) - 화면이 없는 리눅스 서버에서 Flutter 위젯을 그려내기 위한 가상 모니터 역할 수행

### 3.3. Python (또는 Dart)
* **역할**: 완성된 이미지를 인스타그램에 게시
* **안전한 업로드 방식**: **Instagram Graph API (공식 API)**
  * 비공식 봇 라이브러리(`instagrapi` 등)는 계정 정지(블락) 위험이 매우 큼.
  * 페이스북 페이지와 연동된 인스타그램 '프로페셔널(비즈니스/크리에이터) 계정'으로 전환 후, 공식 API 토큰을 발급받아 안전하게 업로드.

## 4. 모듈별 기능 명세
### A. 급식 데이터 수집 모듈 (Dart)
* **입력**: 학교코드(SD_SCHUL_CODE), 교육청코드(ATPT_OFCDC_SC_CODE), 날짜(YYYYMMDD)
* **출력**: 정제된 중식/석식 메뉴 리스트 (JSON 또는 Dart 객체)
* **예외 처리**: 주말, 방학 등 급식이 없는 날에는 파이프라인을 중단(Skip)하도록 처리.

### B. 위젯 렌더링 및 이미지화 모듈 (Dart/Flutter Test)
* **기능**: 수집된 데이터를 바탕으로 앱 화면 짜듯이 `1080x1080` 규격의 이쁜 Flutter 위젯을 디자인.
* **실행 방식**: 앱을 실행하는 대신 `flutter test` 환경에서 위젯을 메모리에 올리고 `screenshot` 패키지로 찍어냄.

### C. 자동 업로드 모듈 (Python/Requests)
* **기능**: GitHub Secrets에 저장된 공식 API Token(Page Access Token, IG User ID)을 환경변수로 받아 공식 Graph API 엔드포인트로 사진 전송 및 게시물 발행.
