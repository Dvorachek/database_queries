
# This script was used to generate the model output for this test case.
# It assumes that your solution is in the directory ../solution

# Re-run the create_schema.txt script to clear and re-populate the database
# psql -h studdb1.csc.uvic.ca your_db_here your_name_here < create_schema.txt

# Add data - All of these should succeed (and generate no output)
python3 ../solution/create_courses.py  courses.txt
python3 ../solution/add_drop.py  adds_and_drops.txt
python3 ../solution/assign_grades.py  grades.txt

# Generate some reports
python3 ../solution/report_classlist.py "CSC 115" 201801 > output_CSC115_201801_classlist.txt
python3 ../solution/report_enrollment.py > output_enrollment.txt
python3 ../solution/report_transcript.py V00123456 > output_V00123456_transcript.txt