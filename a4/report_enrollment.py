# report_enrollment.py
# CSC 370 - Spring 2018 - Starter code for Assignment 4
#
# Dylan Dvorachek
# V00863468
#
# The code below generates a mockup of the output of report_enrollment.py
# as specified in the assignment. You can copy and paste the functions in this
# program into your solution to ensure the correct formatting.
#
# B. Bird - 02/26/2018

import psycopg2, sys

def e(func, conn):  # wrapper for error handling
    def wrapper(*args, **kwargs):
        try:
            func(*args, **kwargs)
        except psycopg2.ProgrammingError as err:
            #ProgrammingError is thrown when the database error is related to the format of the query (e.g. syntax error)
            print("Caught a ProgrammingError:",file=sys.stderr)
            print(err,file=sys.stderr)
            conn.rollback()
            sys.exit(0)
        except psycopg2.IntegrityError as err: 
            #IntegrityError occurs when a constraint (primary key, foreign key, check constraint or trigger constraint) is violated.
            print("Caught an IntegrityError:",file=sys.stderr)
            print(err,file=sys.stderr)
            conn.rollback()
            sys.exit(0)
        except psycopg2.InternalError as err:  
            #InternalError generally represents a legitimate connection error, but may occur in conjunction with user defined functions.
            #In particular, InternalError occurs if you attempt to continue using a cursor object after the transaction has been aborted.
            #(To reset the connection, run conn.rollback() and conn.reset(), then make a new cursor)
            print("Caught an IntegrityError:",file=sys.stderr)
            print(err,file=sys.stderr)
            conn.rollback()
            sys.exit(0)

def print_row(term, course_code, course_name, instructor_name, total_enrollment, maximum_capacity):
    print("%6s %10s %-35s %-25s %s/%s"%(str(term), str(course_code), str(course_name), str(instructor_name), str(total_enrollment), str(maximum_capacity)) )

# Open your DB connection here
psql_user = 'dvorache'
psql_db = 'dvorache'
psql_password = 'pineapple'
psql_server = 'studdb2.csc.uvic.ca'
psql_port = 5432

conn = psycopg2.connect(dbname=psql_db, user=psql_user, password=psql_password, host=psql_server, port=psql_port)

cursor = conn.cursor()

e(cursor.execute("""select P1.course_code, P1.term_code, P1.course_name, P1.instructor_name, count(P2.student_id), P1.capacity
    from course_offering as P1 left join enrollment as P2
    on P1.course_code = P2.course_code
    and P1.term_code = P2.term_code
    group by P1.course_code, P1.term_code, P1.course_name, P1.instructor_name, P1.capacity
    order by P1.term_code, P1.course_code;
    """), conn)

rows_found = 0
row = cursor.fetchone()
while row:
    term, course_code, course_name, instructor_name, total_enrollment, maximum_capacity = row
    print_row(term, course_code, course_name, instructor_name, total_enrollment, maximum_capacity)
    row = cursor.fetchone()
    rows_found += 1

cursor.close()
conn.close()
