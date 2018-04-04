
# This script was used to generate the model output for this test case.
# It assumes that your solution is in the directory ../solution

# Re-run the create_schema.txt script to clear and re-populate the database
# psql -h studdb1.csc.uvic.ca your_db_here your_name_here < create_schema.txt

# All of the data entry commands below should succeed and generate no output.

python3 ../solution/create_courses.py  courses.txt
python3 ../solution/add_drop.py  adds_and_drops1.txt

# Now, try to add V00123458 to CSC 187 in 201805. This should fail since that particular offering of the course
# has a prerequisite (even though other offerings do not) and the student has not met the prerequisite.
echo 'Attempting to add V00123458 to CSC 187 (should fail)'
python3 ../solution/add_drop.py  adds_and_drops2.txt

# Now, try to add V00123459 to CSC 188 in 201709. This should fail since CSC 188 requires CSC 187, and although V00123459
# is registered in CSC 187, the registration is in the same semester (not an earlier semester).
echo 'Attempting to add V00123459 to CSC 188 (should fail)'
python3 ../solution/add_drop.py  adds_and_drops3.txt


# Generate a transcript for V00123458 (which should not contain an entry for CSC 187)
python3 ../solution/report_transcript.py V00123458 > output_V00123458_transcript.txt
# Generate a transcript for V00123459 (which should not contain an entry for CSC 188)
python3 ../solution/report_transcript.py V00123459 > output_V00123459_transcript.txt