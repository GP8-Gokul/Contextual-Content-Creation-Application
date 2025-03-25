from connect import get_cursor,commit

def get_studyplan(user_id,s_id):
    cursor = get_cursor()
    cursor.execute("SELECT content FROM study_plan WHERE s_id = ?", (s_id,))
    row = cursor.fetchone()
    commit()
    return row[0] if row else None