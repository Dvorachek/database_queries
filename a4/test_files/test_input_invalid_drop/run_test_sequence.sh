
# This script was used to generate the model output for this test case.
# It assumes that your solution is in the directory ../solution

# Re-run the create_schema.txt script to clear and re-populate the database
# psql -h studdb1.csc.uvic.ca your_db_here your_name_here < create_schema.txt

# All of the data entry commands below should succeed and generate no output.

python3 ../solution/create_courses.py  courses.txt
python3 ../solution/add_drop.py  adds_and_drops1.txt
python3 ../solution/add_drop.py  adds_and_drops2.txt
python3 ../solution/assign_grades.py  grades.txt
python3 ../solution/add_drop.py  adds_and_drops3.txt

# Now, try to drop V00123457 from CSC 110 (for which a grade has been assigned). This should fail.

echo 'Attempting to drop V00123457 from CSC 110 (should fail)'
python3 ../solution/add_drop.py  adds_and_drops4.txt

# Generate a transcript for V00123456
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript.txt
# Generate a transcript for V00123457
python3 ../solution/report_transcript.py V00123457 > output_V00123457_transcript.txt
# Generate a transcript for V00123458
python3 ../solution/report_transcript.py V00123458 > output_V00123458_transcript.txt
