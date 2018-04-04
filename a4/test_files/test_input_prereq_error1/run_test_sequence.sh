
# This script was used to generate the model output for this test case.
# It assumes that your solution is in the directory ../solution

# Re-run the create_schema.txt script to clear and re-populate the database
# psql -h studdb1.csc.uvic.ca your_db_here your_name_here < create_schema.txt

# All of the data entry commands below should succeed and generate no output.

python3 ../solution/create_courses.py  courses.txt
python3 ../solution/add_drop.py  adds_and_drops1.txt
python3 ../solution/assign_grades.py  grades.txt

# Now, try to add V00123456 to CSC 115 in 201801 (this should fail because V00123456 failed the prerequisite)
echo 'Attempting to add V00123456 to CSC 115 (should fail)'
python3 ../solution/add_drop.py  adds_and_drops2.txt

# Generate a transcript for V00123456 (which should not contain an entry for CSC 115)
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript.txt

# Now, try to add V00123457 to CSC 225 in 201805 (this should fail because V00123457 is missing one of the prerequisites)
echo 'Attempting to add V00123457 to CSC 225 (should fail)'
python3 ../solution/add_drop.py  adds_and_drops3.txt

# Generate a transcript for V00123457 (which should not contain an entry for CSC 225)
python3 ../solution/report_transcript.py V00123457 > output_V00123457_transcript.txt