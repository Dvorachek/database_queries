# report_transcript.py
# CSC 370 - Spring 2018 - Starter code for Assignment 4
#
# The code below generates a mockup of the output of report_transcript.py
# as specified in the assignment. You can copy and paste the functions in this
# program into your solution to ensure the correct formatting.
#
# B. Bird - 02/26/2018

import psycopg2, sys

def e(func, conn):  # created a wrapper for error handling.. because who would really want to write this more than once?
    def wrapper(*args, **kwargs):
        try:
            func(*args, **kwargs)
        except psycopg2.ProgrammingError as err:
            #ProgrammingError is thrown when the database error is related to the format of the query (e.g. syntax error)
            print("Caught a ProgrammingError:",file=sys.stderr)
            print(err,file=sys.stderr)
            conn.rollback()
            sys.exit(1)
        except psycopg2.IntegrityError as err: 
            #IntegrityError occurs when a constraint (primary key, foreign key, check constraint or trigger constraint) is violated.
            print("Caught an IntegrityError:",file=sys.stderr)
            print(err,file=sys.stderr)
            conn.rollback()
            sys.exit(1)
        except psycopg2.InternalError as err:  
            #InternalError generally represents a legitimate connection error, but may occur in conjunction with user defined functions.
            #In particular, InternalError occurs if you attempt to continue using a cursor object after the transaction has been aborted.
            #(To reset the connection, run conn.rollback() and conn.reset(), then make a new cursor)
            print("Caught an IntegrityError:",file=sys.stderr)
            print(err,file=sys.stderr)
            conn.rollback()
            sys.exit(1)

def print_header(student_id, student_name):
    print("Transcript for %s (%s)"%(str(student_id), str(student_name)) )
    
def print_row(course_term, course_code, course_name, grade):
    if grade is not None:
        print("%6s %10s %-35s   GRADE: %s"%(str(course_term), str(course_code), str(course_name), str(grade)) )
    else:
        print("%6s %10s %-35s   (NO GRADE ASSIGNED)"%(str(course_term), str(course_code), str(course_name)) )

#''' The lines below would be helpful in your solution
if len(sys.argv) < 2:
    print('Usage: %s <student id>'%sys.argv[0], file=sys.stderr)
    sys.exit(0)
    
student_id = sys.argv[1]
# '''

# Open your DB connection here
psql_user = 'dvorache'  # when I started at uvic the maximum character lenght was 8.. I'm glad it's now been upgraded
psql_db = 'dvorache'
psql_password = 'pineapple'
psql_server = 'studdb2.csc.uvic.ca'
psql_port = 5432

conn = psycopg2.connect(dbname=psql_db, user=psql_user, password=psql_password, host=psql_server, port=psql_port)

cursor = conn.cursor()

e(cursor.execute("""select student_id, student_name, course_code, term_code, course_name, grade
    from students
    natural join
    grades
    natural join
    course_offering
    where student_id = %s;""", (student_id,)), conn)
    
_,student_name,_,_,_ = row[:5]

print_header(student_id, student_name)

while row:
    grade = None if len(row) < 5 else row[5]
    _,_,course_code,term,course_name = row[:5]
    print_row(term, course_code, course_name, grade)
    row = cursor.fetchone()

cursor.close()
conn.close()
# Mockup: Print a transcript for V00123456 (Rebecca Raspberry)
# student_id = 'V00123456'
# student_name = 'Rebecca Raspberry'
# print_header(student_id, student_name)


# print_row(201709,'CSC 110','Fundamentals of Programming: I', 90)
# print_row(201709,'CSC 187','Recursive Algorithm Design', None) #The special value None is used to indicate that no grade is assigned.
# print_row(201801,'CSC 115','Fundamentals of Programming: II', 75)