import sqlitecloud

def get_cursor():
    global conn 
    conn = sqlitecloud.connect("")
    conn.execute("PRAGMA foreign_keys = ON")
    cursor=conn.cursor()
    return cursor

def commit():
    conn.commit()
    conn.close()
