from instagrapi import Client 

cl = Client()
cl.login('ush_lunch_account', 'a12345678')
cl.dump_settings("session.json") 
