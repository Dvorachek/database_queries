# report_classlist.py
# CSC 370 - Spring 2018 - Starter code for Assignment 4
#
# The code below generates a mockup of the output of report_classlist.py
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
            
def print_header(course_code, course_name, term, instructor_name):
    print("Class list for %s (%s)"%(str(course_code), str(course_name)) )
    print("  Term %s"%(str(term), ) )
    print("  Instructor: %s"%(str(instructor_name), ) )
    
def print_row(student_id, student_name, grade):
    if grade is not None:
        print("%10s %-25s   GRADE: %s"%(str(student_id), str(student_name), str(grade)) )
    else:
        print("%10s %-25s"%(str(student_id), str(student_name),) )

def print_footer(total_enrolled, max_capacity):
    print("%s/%s students enrolled"%(str(total_enrolled),str(max_capacity)) )


#''' The lines below would be helpful in your solution
if len(sys.argv) < 3:
    print('Usage: %s <course code> <term>'%sys.argv[0], file=sys.stderr)
    sys.exit(0)
    
course_code, term = sys.argv[1:3]
#'''

# Open your DB connection here
psql_user = 'dvorache'  # when I started at uvic the maximum character lenght was 8.. I'm glad it's now been upgraded
psql_db = 'dvorache'
psql_password = 'pineapple'
psql_server = 'studdb2.csc.uvic.ca'
psql_port = 5432

conn = psycopg2.connect(dbname=psql_db, user=psql_user, password=psql_password, host=psql_server, port=psql_port)

cursor = conn.cursor()

e(cursor.execute("""select *
    from course_offering
    natural join
    enrollment
    natural join
    students
    natural join
    grades
    where course_code = %s and term_code = %s;""", (course_code, term)), conn)  # so many joins

row = cursor.fetchone()
if row:
    _, _, _, course_name, instructor_name, capacity, _ = row[:7]
    print_header(course_code, course_name, term, instructor_name)
row_count = 0
while row:
    row_count += 1
    student_id, _, _, _, _, _, student_name = row[:7]
    grade = None if len(row) < 7 else row[7]
    print_row(student_id, student_name, grade)
    row = cursor.fetchone()
  
print_footer(row_count, capacity)

cursor.close()
conn.close()
