import sqlite3

db = "backend/studyplanner.db"

create_users = '''
    CREATE TABLE users(
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR NOT NULL,
    password VARCHAR NOT NULL, 
    email VARCHAR NOT NULL 
    );
'''

create_study_plan = '''
    CREATE TABLE study_plan(
    s_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    content JSON,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
'''


# Connect to SQLite database
conn = sqlite3.connect(db)

# Create a cursor
cur = conn.cursor()
cur.execute(create_users)
cur.execute(create_study_plan)
conn.commit()
print("Tables created successfully.")

# Close connection
conn.close()
