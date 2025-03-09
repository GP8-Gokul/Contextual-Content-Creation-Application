import firebase_admin
from firebase_admin import credentials, db

cred = credentials.Certificate("backend/key.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app'
})


def addtofirebase(userid, s_id, content):
    try:
        ref = db.reference(f'users/{userid}/studyplan/{s_id}')  
        ref.update({'content': content})
        return "Data added successfully!"
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    test_userid = "2erBRngXiweBgYpkkn9j35Ms6Y32"
    test_s_id = "1"
    test_content = {
        "Frog":{
            "Summary": "animal",
            "Elaboration":"bird",
            "pages": "crow"
        },
        "Dog":{
            "Summary": "animal",
            "Elaboration":"bird",
            "pages": "king"
        },
    }

    result = addtofirebase(test_userid, test_s_id, test_content)
    print(result)  
