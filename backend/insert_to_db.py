import json

from connect import commit, get_cursor

def save_to_db(content,user_id,s_id):
    cursor=get_cursor()
    cursor.execute("UPDATE study_plan SET content = ? WHERE s_id = ?", (json.dumps(content), s_id))
    commit()