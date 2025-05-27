import cx_Oracle

dsn = cx_Oracle.makedsn("asapprdstdby.corp.pvt", 1521, service_name="asapprd")
conn = cx_Oracle.connect(user="ASAP", password='asap', dsn=dsn)

print("Successfully connected to Oracle Database")
conn.close()
