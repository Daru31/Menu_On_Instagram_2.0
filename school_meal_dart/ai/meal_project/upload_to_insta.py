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
    session_data = os.environ.get('IG_SESSION')
    
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
    
    # GitHub Secrets에 등록된 IG_SESSION이 있다면 파일로 생성해서 사용합니다.
    if session_data:
        try:
            with open(session_file, "w", encoding="utf-8") as f:
                f.write(session_data)
            print("✅ GitHub Secrets에서 기존 세션(IG_SESSION)을 로드했습니다.")
        except Exception as e:
            print(f"⚠️ 세션 파일 생성 실패: {e}")

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

    from PIL import Image
    from instagrapi.exceptions import PhotoConfigureStoryError

    if lunch_path:
        jpg_path = lunch_path.replace(".png", ".jpg")
        try:
            Image.open(lunch_path).convert("RGB").save(jpg_path, "JPEG", quality=95)
            abs_path = os.path.abspath(jpg_path)
            print(f"📷 중식 이미지 업로드 중... ({abs_path})")
            cl.photo_upload_to_story(abs_path)
            time.sleep(3)
        except PhotoConfigureStoryError:
            print(f"✅ 중식 사진이 스토리에 올라갔습니다. (라이브러리 자체 파싱 에러 무시)")
        except Exception as e:
            print(f"❌ 중식 이미지 업로드 실패: {e}")
    else:
        print("⚠️ 중식 이미지를 찾을 수 없습니다.")
        
    if dinner_path:
        jpg_path = dinner_path.replace(".png", ".jpg")
        try:
            Image.open(dinner_path).convert("RGB").save(jpg_path, "JPEG", quality=95)
            abs_path = os.path.abspath(jpg_path)
            print(f"📷 석식 이미지 업로드 중... ({abs_path})")
            cl.photo_upload_to_story(abs_path)
        except PhotoConfigureStoryError:
            print(f"✅ 석식 사진이 스토리에 올라갔습니다. (라이브러리 자체 파싱 에러 무시)")
        except Exception as e:
            print(f"❌ 석식 이미지 업로드 실패: {e}")
    else:
        print("⚠️ 석식 이미지를 찾을 수 없습니다.")

    print("🎉 인스타그램 스토리 업로드 완료!")

if __name__ == "__main__":
    upload_images()
