# report_enrollment.py
# CSC 370 - Spring 2018 - Starter code for Assignment 4
#
# The code below generates a mockup of the output of report_enrollment.py
# as specified in the assignment. You can copy and paste the functions in this
# program into your solution to ensure the correct formatting.
#
# B. Bird - 02/26/2018

import psycopg2, sys

def print_row(term, course_code, course_name, instructor_name, total_enrollment, maximum_capacity):
    print("%6s %10s %-35s %-25s %s/%s"%(str(term), str(course_code), str(course_name), str(instructor_name), str(total_enrollment), str(maximum_capacity)) )

# Mockup: Print some data for a few made up classes

# print_row(201709, 'CSC 106', 'The Practice of Computer Science', 'Bill Bird', 203, 215)
# print_row(201709, 'CSC 110', 'Fundamentals of Programming: I', 'Jens Weber', 166, 200)
# print_row(201801, 'CSC 370', 'Database Systems', 'Bill Bird', 146, 150)

# Open your DB connection here
psql_user = 'dvorache'  # when I started at uvic the maximum character lenght was 8.. I'm glad it's now been upgraded
psql_db = 'dvorache'
psql_password = 'pineapple'
psql_server = 'studdb2.csc.uvic.ca'
psql_port = 5432

conn = psycopg2.connect(dbname=psql_db, user=psql_user, password=psql_password, host=psql_server, port=psql_port)

cursor = conn.cursor()

cursor.execute("""select course_code, term_code, course_name, instructor_name, count(student_id), capacity
    from course_offering natural join enrollment
    group by course_code, term_code, course_name, instructor_name, capacity;
    """)

rows_found = 0
row = cursor.fetchone()
while row:
    term, course_code, course_name, instructor_name, total_enrollment, maximum_capacity = row
    print_row(term, course_code, course_name, instructor_name, total_enrollment, maximum_capacity)
    cursor.fetchone()
    rows_found += 1

print("Read %d rows"%rows_found)
cursor.close()
conn.close()
