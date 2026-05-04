from instagrapi import Client 
import os

cl = Client()
username = os.environ.get('IG_USERNAME', 'hidden_username')
password = os.environ.get('IG_PASSWORD', 'hidden_password')
cl.login(username, password)
cl.dump_settings("session.json") 
