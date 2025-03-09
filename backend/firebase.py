import firebase_admin
from firebase_admin import credentials, db

cred = credentials.Certificate("backend/key.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app'
})


def add_to_firebase(userid, s_id, content):
    try:
        ref = db.reference(f'studyplan/{userid}')  
        ref.update({
            's_id': s_id,
            'content': content
        })
        return "Data added successfully!"
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    test_userid = "2erBRngXiweBgYpkkn9j35Ms6Y32"
    test_s_id = "1"
    test_content = "Complete Python project by Sunday"

    result = add_to_firebase(test_userid, test_s_id, test_content)
    print(result)  
