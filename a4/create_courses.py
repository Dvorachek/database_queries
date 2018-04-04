# create_courses.py
# CSC 370 - Spring 2018 - Starter code for Assignment 4
#
#
# B. Bird - 02/26/2018

import sys, csv, psycopg2

if len(sys.argv) < 2:
    print("Usage: %s <input file>",file=sys.stderr)
    sys.exit(0)
    
input_filename = sys.argv[1]

# Open your DB connection here
psql_user = 'dvorache'  # when I started at uvic the maximum character lenght was 8.. I'm glad it's now been upgraded
psql_db = 'dvorache'
psql_password = ''
psql_server = 'studdb2.csc.uvic.ca'
psql_port = 5432

conn = psycopg2.connect(dbname=psql_db, user=psql_user, password=psql_password, host=psql_server, port=psql_port)

cursor = conn.cursor()

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

with open(input_filename) as f:
    for row in csv.reader(f):
        if len(row) == 0:
            continue #Ignore blank rows
        if len(row) < 4:
            print("Error: Invalid input line \"%s\""%(','.join(row)), file=sys.stderr)
            #Maybe abort the active transaction and roll back at this point?
            break
        code, name, term, instructor, capacity = row[0:5]
        prerequisites = row[5:] #List of zero or more items
        
        #Do something with the data here
        #Make sure to catch any exceptions that occur and roll back the transaction if a database error occurs.
        e(cursor.execute("insert into courses values( %s );", (code)), conn)
        e(cursor.execute("insert into course_offerings values( %s, %s, %s, %s, %s );", (code, name, term, instructor, capacity)), conn)
        [e(cursor.execure("insert into prerequisites values( %s, %s );", (prerequisites[0], pre_req)), conn) for pre_req in prerequisites[1:]]
        
      
conn.commit()
cursor.close()
conn.close()
