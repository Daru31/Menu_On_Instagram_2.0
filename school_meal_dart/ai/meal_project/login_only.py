import os
import time
import traceback
import json
from instagrapi import Client
from instagrapi.mixins.challenge import ChallengeChoice
import getpass

def challenge_code_handler(username, choice):
    if choice == ChallengeChoice.SMS:
        return input(f"📱 [{username}] SMS로 전송된 6자리 인증번호를 입력하세요: ")
    elif choice == ChallengeChoice.EMAIL:
        return input(f"📧 [{username}] 이메일로 전송된 6자리 인증번호를 입력하세요: ")
    return input(f"🔐 [{username}] 인증번호를 입력하세요 (방식: {choice}): ")

def local_login_and_save_session():
    print("====================================")
    print("🔑 인스타그램 로컬 세션(session.json) 발급기")
    print("====================================")
    print("현재 계정이 봇으로 의심받아 강력한 차단(checkpoint)이 걸린 상태일 수 있습니다.")
    print("이런 경우 PC 브라우저에서 인스타그램에 로그인한 후, 'sessionid' 쿠키 값을 가져와서")
    print("직접 로그인하는 방식이 가장 안전하고 확실합니다.\n")
    
    print("1. 아이디 / 비밀번호로 로그인 시도 (기존 방식)")
    print("2. PC 브라우저 쿠키(sessionid)로 로그인 시도 (추천 🌟)")
    choice = input("\n원하는 로그인 방식을 선택하세요 (1 또는 2): ")
    
    cl = Client()
    cl.delay_range = [1, 3]
    cl.challenge_code_handler = challenge_code_handler
    session_file = "session.json"
    
    if os.path.exists(session_file):
        cl.load_settings(session_file)
        print("💡 기존 기기 정보를 불러왔습니다.")

    try:
        if choice == '1':
            username = input("\n인스타그램 아이디(ID): ")
            password = getpass.getpass("인스타그램 비밀번호(입력시 안보임): ")
            print(f"\n🚀 '{username}' 계정으로 아이디/비밀번호 로그인을 시도합니다...")
            cl.dump_settings(session_file)
            cl.login(username, password)
            cl.dump_settings(session_file)
        
        elif choice == '2':
            print("\n[sessionid 가져오는 방법]")
            print("1. PC 크롬(Chrome) 브라우저 시크릿 모드를 엽니다.")
            print("2. instagram.com 에 접속해서 직접 수동으로 로그인합니다.")
            print("3. F12 키를 눌러 개발자 도구를 엽니다.")
            print("4. 상단 탭에서 'Application(애플리케이션)' 을 클릭합니다.")
            print("5. 좌측 메뉴에서 'Cookies' -> 'https://www.instagram.com' 을 클릭합니다.")
            print("6. 우측 목록에서 Name이 'sessionid' 인 항목을 찾습니다.")
            print("7. 그 항목의 Value 값을 더블클릭해서 복사(Ctrl+C) 합니다.")
            
            session_id_value = getpass.getpass("\n복사한 sessionid 값을 붙여넣기(우클릭/Ctrl+V) 하세요: ")
            
            print("\n🚀 sessionid로 로그인을 시도합니다...")
            cl.login_by_sessionid(session_id_value)
            cl.dump_settings(session_file)
        else:
            print("잘못된 입력입니다.")
            return

        print("\n🎉 로그인 성공! 'session.json' 파일이 생성/업데이트 되었습니다.")
        print(f"👉 파일 위치: {os.path.abspath(session_file)}")
        print("\n💡 이제 생성된 session.json 파일의 모든 내용을 복사해서 GitHub Secrets의 'IG_SESSION' 에 붙여넣어 주세요!")
        
    except Exception as e:
        print(f"\n❌ 로그인 중 오류가 발생했습니다: {e}")
        
        # 상세 오류 로그를 파일로 저장
        with open("instagram_error.txt", "w", encoding="utf-8") as f:
            f.write(f"Exception: {str(e)}\n\n")
            f.write("Traceback:\n")
            f.write(traceback.format_exc() + "\n\n")
            f.write("Last JSON Response from Instagram API:\n")
            try:
                f.write(json.dumps(cl.last_json, indent=4, ensure_ascii=False))
            except Exception as json_e:
                f.write(f"Could not parse last_json: {json_e}")
                
        print("\n🔍 상세 에러 로그가 'instagram_error.txt' 파일에 저장되었습니다.")

if __name__ == "__main__":
    local_login_and_save_session()
