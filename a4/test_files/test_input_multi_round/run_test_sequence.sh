
# This script was used to generate the model output for this test case.
# It assumes that your solution is in the directory ../solution

# Re-run the create_schema.txt script to clear and re-populate the database
# psql -h studdb1.csc.uvic.ca your_db_here your_name_here < create_schema.txt

# All of the data entry commands below should succeed and generate no output.

python3 ../solution/create_courses.py  courses1.txt
python3 ../solution/add_drop.py  adds_and_drops1.txt
# Generate a transcript for V00123456 (which should have no grades)
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript1.txt
python3 ../solution/assign_grades.py  grades1.txt
# Generate another transcript for V00123456 (which should have grades for everything)
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript2.txt

python3 ../solution/create_courses.py  courses2.txt
# Generate an enrollment report
python3 ../solution/report_enrollment.py > output_enrollment1.txt
python3 ../solution/add_drop.py  adds_and_drops2.txt
# Generate another transcript for V00123456 (which will have some grades, but also some courses without grades)
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript3.txt
python3 ../solution/assign_grades.py  grades2.txt
# Generate transcripts for V00123456 and V00123457
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript4.txt
python3 ../solution/report_transcript.py V00123457 > output_V00123457_transcript1.txt
python3 ../solution/assign_grades.py  grades3.txt
# Generate more transcripts for V00123456 and V00123457
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript5.txt
python3 ../solution/report_transcript.py V00123457 > output_V00123457_transcript2.txt

# Generate an enrollment report
python3 ../solution/report_enrollment.py > output_enrollment1.txt
# Generate a class list for CSC 225 in 201805
python3 ../solution/report_classlist.py "CSC 225" 201805 > output_CSC225_201805_classlist.txt