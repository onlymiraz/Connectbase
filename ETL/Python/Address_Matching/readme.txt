Summary:
This ETL process takes two tables with address columns and attempts to match
them as accurately as possible. The output is 1 table with matches.


Details:
The output is a cartesian join for all address matches. For example, row 1 in
the left table can join to rows 10, 15, and 20 in the right table, resulting
in 3 different output records.

Script main.py imports and runs the functions from process_raw_addresses.py,
which is where the string cleaning, parsing, and matching work takes place.

Script connect.py provides connections for querying and writing data to and
from sql server.


Note on modularity:
1. This project assumes both input columns have the following 4 columns:
ADDRESS, CITY, STATE, ZIP.
For another project, column names may need to be altered in the script
process_raw_addresses.py.
2. All servers, databases, schemas, tables, and queries are hardcoded in
the script connect.py. These may need to be updated for a different project.
