import os
import time
from instagrapi import Client
import getpass

def local_login_and_save_session():
    print("====================================")
    print("🔑 인스타그램 로컬 세션(session.json) 발급기")
    print("====================================")
    
    username = input("인스타그램 아이디(ID): ")
    password = getpass.getpass("인스타그램 비밀번호(입력시 안보임): ")

    cl = Client()
    cl.delay_range = [1, 3]

    print(f"\n🚀 '{username}' 계정으로 로그인을 시도합니다...")
    try:
        # 로그인 시도 (이때 휴대폰으로 인증번호가 날아오거나, 프롬프트 창에 인증번호를 입력하라는 메시지가 뜰 수 있습니다.)
        cl.login(username, password)
        
        # 로그인 성공 시 쿠키/세션 정보 저장
        session_file = "session.json"
        cl.dump_settings(session_file)
        
        print("\n🎉 로그인 성공! 'session.json' 파일이 생성되었습니다.")
        print(f"👉 파일 위치: {os.path.abspath(session_file)}")
        print("\n💡 이제 생성된 session.json 파일의 모든 내용을 복사해서 GitHub Secrets의 'IG_SESSION' 에 붙여넣어 주세요!")
        
    except Exception as e:
        print(f"\n❌ 로그인 중 오류가 발생했습니다: {e}")
        print("만약 ChallengeChoice.SMS(문자인증) 관련 오류가 났다면, 터미널(CMD)에서 요구하는 인증번호 6자리를 입력해주세요.")

if __name__ == "__main__":
    local_login_and_save_session()
