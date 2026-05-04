import os
from instagrapi import Client
from PIL import Image

cl = Client()
cl.load_settings("session.json")
cl.login("ush_lunch_account", os.environ.get('IG_PASSWORD', 'a12345678'))

# Create a generic small red square image
img = Image.new('RGB', (1080, 1080), color = 'red')
img.save('test_red.jpg')

print("Uploading generic red image...")
try:
    cl.photo_upload('test_red.jpg', "Test red image.")
    print("Success!")
except Exception as e:
    print(f"Failed: {e}")
