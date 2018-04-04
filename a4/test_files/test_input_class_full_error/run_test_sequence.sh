
# This script was used to generate the model output for this test case.
# It assumes that your solution is in the directory ../solution

# Re-run the create_schema.txt script to clear and re-populate the database
# psql -h studdb1.csc.uvic.ca your_db_here your_name_here < create_schema.txt

# All of the data entry commands below should succeed and generate no output.

python3 ../solution/create_courses.py  courses.txt
python3 ../solution/add_drop.py  adds_and_drops1.txt

# Now, try to add V00123458 to CSC 187 in 201709 (this should fail because the course is full)
echo 'Attempting to add V00123458 to CSC 187 (should fail)'
python3 ../solution/add_drop.py  adds_and_drops2.txt

# Attempt to generate a transcript for V00123458 (which should fail, since the student should
# not exist, due to the failure of the add_drop script above)
echo 'Trying to generate a transcript (should fail)'
python3 ../solution/report_transcript.py V00123458
