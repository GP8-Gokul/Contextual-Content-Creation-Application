import sqlitecloud

def get_cursor():
    global conn 
    conn = sqlitecloud.connect("sqlitecloud://cgzby8cphz.g1.sqlite.cloud:8860/studyplanner.db?apikey=CKbk1dKMFgJKoiIXCg9lJteo5I1HwUPhqJdvNzbcsGE")
    conn.execute("PRAGMA foreign_keys = ON")
    cursor=conn.cursor()
    return cursor

def commit():
    conn.commit()
    conn.close()