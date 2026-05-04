import os
import glob
import time
from instagrapi import Client

def get_latest_image(pattern):
    files = glob.glob(pattern)
    if not files:
        return None
    return max(files, key=os.path.getmtime)

def upload_images():
    username = os.environ.get('IG_USERNAME')
    password = os.environ.get('IG_PASSWORD')
    
    if not username or not password:
        print("❌ 환경변수(IG_USERNAME, IG_PASSWORD)가 설정되지 않았습니다. 업로드를 건너뜁니다.")
        return

    lunch_path = get_latest_image('images/*_lunch.png')
    dinner_path = get_latest_image('images/*_dinner.png')

    if not lunch_path and not dinner_path:
        print("❌ 업로드할 이미지가 images 폴더에 없습니다.")
        return

    print(f"🚀 인스타그램 로그인 시도 중... (계정: {username})")
    cl = Client()
    cl.delay_range = [1, 3]
    
    session_file = "session.json"
    try:
        if os.path.exists(session_file):
            cl.load_settings(session_file)
    except Exception as e:
        print(f"⚠️ 세션 로드 실패: {e}")

    try:
        cl.login(username, password)
        cl.dump_settings(session_file)
    except Exception as e:
        print(f"❌ 로그인 실패: {e}")
        return

    print("✅ 로그인 성공!")

    if lunch_path:
        print(f"📷 중식 이미지 업로드 중... ({lunch_path})")
        cl.photo_upload_to_story(lunch_path)
        time.sleep(3)
    else:
        print("⚠️ 중식 이미지를 찾을 수 없습니다.")
        
    if dinner_path:
        print(f"📷 석식 이미지 업로드 중... ({dinner_path})")
        cl.photo_upload_to_story(dinner_path)
    else:
        print("⚠️ 석식 이미지를 찾을 수 없습니다.")

    print("🎉 인스타그램 스토리 업로드 완료!")

if __name__ == "__main__":
    upload_images()
