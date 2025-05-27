import pyodbc
import socket

# Define the connection and schema details
node_db_mapping = {
    'WADINFWWAPV02': ('WAD_PRD_Integration', 'WAD_PRD_02'),
    'WADINFWWDDV01': ('WAD_STG_Integration', 'WAD_STG_02')
}

current_node = socket.gethostname().upper()
integration_db, prod_db = node_db_mapping.get(current_node, ('Playground', 'Playground'))

connection_string = (
    f"Driver={{ODBC Driver 17 for SQL Server}};"
    f"Server={current_node};"
    f"Database={integration_db};"
    "Trusted_Connection=yes;"
)

schema_name = 'LZ_Py_CircuitInventory'

# Establish connection to the database
conn = pyodbc.connect(connection_string)
cursor = conn.cursor()

# Define the view patterns
view_patterns = {
    "ALL_ACTIVE_UNION_VIEW": "ALL_ACTIVE_%",
    "ALL_DISCO_UNION_VIEW": "ALL_DISCO_%"
}

# Function to drop the view if it exists
def drop_view_if_exists(view_name):
    drop_view_sql = f"""
    IF OBJECT_ID('{schema_name}.{view_name}', 'V') IS NOT NULL
    BEGIN
        DROP VIEW [{schema_name}].[{view_name}];
    END
    """
    cursor.execute(drop_view_sql)
    conn.commit()

# Function to get tables matching a specific pattern in the schema
def get_tables_matching_pattern(pattern):
    query = f"""
    SELECT TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{schema_name}' AND TABLE_NAME LIKE '{pattern}'
    """
    cursor.execute(query)
    return [row[0] for row in cursor.fetchall()]

# Function to get columns for a table
def get_table_columns(table_name):
    query = f"""
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = '{schema_name}' AND TABLE_NAME = '{table_name}'
    """
    cursor.execute(query)
    return [row[0] for row in cursor.fetchall()]

# Function to create a union view with aligned columns, avoiding duplicate column names
def create_union_view(view_name, tables):
    if not tables:
        print(f"No tables found for pattern matching {view_name}. Skipping view creation.")
        return None

    all_columns = set()
    table_columns = {}
    for table in tables:
        columns = get_table_columns(table)
        table_columns[table] = columns
        all_columns.update(columns)

    all_columns = sorted(all_columns)
    all_columns = [col for col in all_columns if col not in ['State', 'ENV']]
    aligned_selects = []

    for table in tables:
        select_columns = []
        for column in all_columns:
            if column in table_columns[table]:
                select_columns.append(f"[{column}]")
            else:
                select_columns.append(f"NULL AS [{column}]")

        aligned_selects.append(f"SELECT {', '.join(select_columns)} FROM [{schema_name}].[{table}]")

    union_query = " UNION ALL ".join(aligned_selects)

    view_sql = f"""
    CREATE VIEW [{schema_name}].[{view_name}] AS
    SELECT 
        cct.State,
        cct.ENV,
        {', '.join(all_columns)}
    FROM 
        ({union_query}) AS disco
    LEFT JOIN 
        [{integration_db}].[{schema_name}].[CABS_Co_Table_CABS_Co_Table] AS cct
    ON 
        disco.[COMP] = cct.[4_Chara_Co];
    """
    return view_sql

# Create the main views
for view_name, pattern in view_patterns.items():
    try:
        drop_view_if_exists(view_name)
        tables = get_tables_matching_pattern(pattern)
        view_sql = create_union_view(view_name, tables)

        if view_sql:
            cursor.execute(view_sql)
            conn.commit()
            print(f"View {schema_name}.{view_name} created successfully.")
        else:
            print(f"Skipped creation of {view_name} due to no matching tables.")

    except pyodbc.Error as e:
        print(f"Error creating view {schema_name}.{view_name}: {e}")

# Function to create the master view that combines both active and disco views
def create_master_view():
    drop_view_if_exists("MASTER_ACTIVE_DISCO_VIEW")

    master_view_sql = f"""
    CREATE VIEW [{schema_name}].[MASTER_ACTIVE_DISCO_VIEW] AS
    SELECT * 
    FROM (
        SELECT 
            'ACTIVE' AS RECORD_TYPE,
            RIGHT(
                LTRIM(SUBSTRING(
                    LTRIM(DATES_), 
                    CHARINDEX(' ', LTRIM(DATES_)), 
                    LEN(LTRIM(DATES_)) - CHARINDEX(' ', LTRIM(DATES_)) + 1
                )), 8) AS DATES__,
            REPLACE(REPLACE(REPLACE(COMP + EC_ID_ + IXC_ + LEG_, '.', ''), ' ', ''), '-', '') AS UNIQUE_ID,
            REPLACE(REPLACE(REPLACE(EC_ID_, '.', ''), ' ', ''), '-', '') AS CLEAN_ID,
            CASE 
                WHEN CHARINDEX('-', PLAN_ID_) > 0 
                THEN LEFT(PLAN_ID_, CHARINDEX('-', PLAN_ID_) - 1) 
                ELSE PLAN_ID_ 
            END AS PNUM,
            ABC.*
        FROM [{schema_name}].[ALL_ACTIVE_UNION_VIEW] AS ABC

        UNION

        SELECT 
            'DC' AS RECORD_TYPE,
            RIGHT(
                LTRIM(SUBSTRING(
                    LTRIM(DATES_), 
                    CHARINDEX(' ', LTRIM(DATES_)), 
                    LEN(LTRIM(DATES_)) - CHARINDEX(' ', LTRIM(DATES_)) + 1
                )), 8) AS DATES__,
            REPLACE(REPLACE(REPLACE(COMP + EC_ID_ + IXC_ + LEG_, '.', ''), ' ', ''), '-', '') AS UNIQUE_ID,
            REPLACE(REPLACE(REPLACE(EC_ID_, '.', ''), ' ', ''), '-', '') AS CLEAN_ID,
            CASE 
                WHEN CHARINDEX('-', PLAN_ID_) > 0 
                THEN LEFT(PLAN_ID_, CHARINDEX('-', PLAN_ID_) - 1) 
                ELSE PLAN_ID_ 
            END AS PNUM,
            DEF.*
        FROM [{schema_name}].[ALL_DISCO_UNION_VIEW] AS DEF
    ) A
    LEFT JOIN (
        SELECT DISTINCT 
            PRIMARY_CARRIER_NM, 
            SECONDARY_ID 
        FROM {prod_db}.DBO.MCL_V 
        WHERE ID_TYPE = 'ACNA'
    ) B
    ON A.ACNA_ = B.SECONDARY_ID;
    """

    cursor.execute(master_view_sql)
    conn.commit()
    print(f"Master view {schema_name}.MASTER_ACTIVE_DISCO_VIEW created successfully.")

# Function to create the MASTER_ACTIVE_DISCO_WebApp view
def create_master_webapp_view():
    drop_view_if_exists("MASTER_ACTIVE_DISCO_WebApp")

    master_webapp_view_sql = f"""
    CREATE VIEW [{schema_name}].[MASTER_ACTIVE_DISCO_WebApp] AS
    WITH datefix AS (
        SELECT
            [RECORD_TYPE],
            [State],
            [ENV],
            REPLACE([ACNA_], '_', '') AS ACNA,
            REPLACE([ACTLCLLI_], '_', '') AS ACTLCLLI,
            REPLACE([BILL_NO_], '_', '') AS BILL_NO,
            REPLACE([CFA_], '_', '') AS CFA,
            [CLASS],
            [COMP],
            REPLACE([DATES_], '_', '') AS DATES,
            [DIS],
            [DISCDATE],
            REPLACE([EC_ID_], '_', '') AS EC_ID,
            REPLACE([END_], '_', '') AS [END],
            REPLACE([END_USER_ADDRESS_], '_', '') AS END_USER_ADDRESS,
            REPLACE([EO_CLLI_], '_', '') AS EO_CLLI,
            REPLACE([INSTALL_], '_', '') AS INSTALL,
            REPLACE([IXC_], '_', '') AS IXC,
            [JUR],
            [LATA],
            REPLACE([LEG_], '_', '') AS LEG,
            REPLACE([NAME_], '_', '') AS NAME,
            REPLACE([NC_], '_', '') AS NC,
            REPLACE([PLAN_ID_], '_', '') AS PLAN_ID,
            [PLNSTS],
            REPLACE([POP_CLLI_], '_', '') AS POP_CLLI,
            REPLACE([POP_MILE_], '_', '') AS POP_MILE,
            REPLACE([RATCH_SW_], '_', '') AS RATCH_SW,
            REPLACE([REM_], '_', '') AS REM,
            REPLACE([START_], '_', '') AS START,
            [TARIF],
            REPLACE([TOTAL_], '_', '') AS TOTAL,
            REPLACE([USOC_], '_', '') AS USOC,
            [USOC_1],
            [USOC_2],
            [USOC_3],
            [USOC_4],
            [USOC_5],
            [USOC_6],
            [USOC_7],
            [USOC_8],
            [USOC_9],
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_], '_', '')) AS AMOUNT,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_1], '_', '')) AS AMOUNT_1,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_2], '_', '')) AS AMOUNT_2,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_3], '_', '')) AS AMOUNT_3,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_4], '_', '')) AS AMOUNT_4,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_5], '_', '')) AS AMOUNT_5,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_6], '_', '')) AS AMOUNT_6,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_7], '_', '')) AS AMOUNT_7,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_8], '_', '')) AS AMOUNT_8,
            TRY_CONVERT(DECIMAL(18,2), REPLACE([_AMOUNT_9], '_', '')) AS AMOUNT_9,
            REPLACE([_BIP_], '_', '') AS BIP,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_], '_', '')) AS QTY,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_1], '_', '')) AS QTY_1,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_2], '_', '')) AS QTY_2,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_3], '_', '')) AS QTY_3,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_4], '_', '')) AS QTY_4,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_5], '_', '')) AS QTY_5,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_6], '_', '')) AS QTY_6,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_7], '_', '')) AS QTY_7,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_8], '_', '')) AS QTY_8,
            TRY_CONVERT(FLOAT, REPLACE([_QTY_9], '_', '')) AS QTY_9,
            RIGHT(DATES_, 8) AS ExtractedDate,
            CONVERT(DATE, RIGHT(DATES_, 8)) AS ConvertedDate
        FROM [{schema_name}].[MASTER_ACTIVE_DISCO_VIEW]
    ),
    latest_date AS (
        SELECT MAX(ConvertedDate) AS LatestDate
        FROM datefix
    )
    SELECT
        [RECORD_TYPE],
        FORMAT(ConvertedDate, 'yyyy-MM-dd') AS Dates,
        [State],
        [ENV],
        ACNA,
        ACTLCLLI,
        BILL_NO,
        CFA,
        [CLASS],
        [COMP],
        [DIS],
        [DISCDATE],
        EC_ID,
        [END],
        END_USER_ADDRESS,
        EO_CLLI,
        INSTALL,
        IXC,
        [JUR],
        [LATA],
        LEG,
        [NAME],
        NC,
        PLAN_ID,
        [PLNSTS],
        POP_CLLI,
        POP_MILE,
        RATCH_SW,
        REM,
        [START],
        [TARIF],
        TOTAL,
        USOC,
        [USOC_1],
        [USOC_2],
        [USOC_3],
        [USOC_4],
        [USOC_5],
        [USOC_6],
        [USOC_7],
        [USOC_8],
        [USOC_9],
        AMOUNT,
        AMOUNT_1,
        AMOUNT_2,
        AMOUNT_3,
        AMOUNT_4,
        AMOUNT_5,
        AMOUNT_6,
        AMOUNT_7,
        AMOUNT_8,
        AMOUNT_9,
        BIP,
        QTY,
        QTY_1,
        QTY_2,
        QTY_3,
        QTY_4,
        QTY_5,
        QTY_6,
        QTY_7,
        QTY_8,
        QTY_9
    FROM datefix df
    INNER JOIN latest_date ld
        ON df.ConvertedDate = ld.LatestDate;
    """

    cursor.execute(master_webapp_view_sql)
    conn.commit()
    print(f"Master WebApp view {schema_name}.MASTER_ACTIVE_DISCO_WebApp created successfully.")

# Create the master views
try:
    create_master_view()
    create_master_webapp_view()
except pyodbc.Error as e:
    print(f"Error creating master views: {e}")
