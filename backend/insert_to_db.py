import json

from backend.connect import commit, get_cursor

def save_to_db(content,user_id):
    cursor=get_cursor()
    cursor.execute("INSERT INTO study_plan (user_id, content) VALUES (?, ?)", (user_id, json.dumps(content)))
    commit()