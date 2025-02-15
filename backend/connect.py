# get_cursor() 
# commit()
 


import sqlite3

db="Backend/Database/disaster.db"


def get_cursor():
    global conn 
    conn = sqlite3.connect(db)
    conn.execute("PRAGMA foreign_keys = ON")
    cursor=conn.cursor()
    return cursor

def commit():
    conn.commit()
    conn.close()