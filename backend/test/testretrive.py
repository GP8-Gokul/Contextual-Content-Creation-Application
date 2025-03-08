from connect import get_cursor,commit


cursor = get_cursor()

# Query to retrieve the row with s_id = 1
cursor.execute("SELECT * FROM study_plan WHERE s_id = ?", (1,))

# Fetch the result
row = cursor.fetchone()

# Print the result
if row:
    with open('backend/testdb.txt', 'w') as file:
        file.write(str(row))
else:
    print("No record found with s_id = 1")

commit()
