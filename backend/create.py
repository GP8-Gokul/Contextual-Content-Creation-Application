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
    pdf_text BLOB NOT NULL,
    keywords TEXT,
    summary TEXT,
    summarized_pdf BLOB,
    elaboration TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
    );
'''

create_day_to_day = '''
    CREATE TABLE day_to_day(
    d_id INTEGER PRIMARY KEY AUTOINCREMENT,
    s_id INTEGER NOT NULL,
    summary TEXT,
    pdf_text_part BLOB,
    elaboration TEXT,
    FOREIGN KEY (s_id) REFERENCES study_plan(s_id) ON DELETE CASCADE
    );
'''

# Connect to SQLite database
conn = sqlite3.connect(db)

# Create a cursor
cur = conn.cursor()
cur.execute(create_users)
cur.execute(create_study_plan)
cur.execute(create_day_to_day)
conn.commit()
print("Tables created successfully.")

# Close connection
conn.close()
