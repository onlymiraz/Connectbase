from datetime import datetime, timedelta
import time
import pandas as pd
import numpy as np
import logging
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
import sys

# Configure logging to file and console with immediate flushing
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# File handler
file_handler = logging.FileHandler('combined_log.txt', mode='w')
file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
file_handler.flush = sys.stdout.flush  # Ensures flush after each log entry
logger.addHandler(file_handler)

# Console handler
console_handler = logging.StreamHandler(sys.stdout)
console_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
console_handler.flush = sys.stdout.flush  # Ensures immediate print to console
logger.addHandler(console_handler)

# SQLAlchemy connection strings for source and destination
source_conn_url = URL.create(
    "mssql+pyodbc",
    query={"odbc_connect": "DRIVER={ODBC Driver 17 for SQL Server};"
                            "SERVER=SQLINFWWDPP210\\DCPRD201RO;"
                            "DATABASE=SIFT;"
                            "Trusted_Connection=yes;"}
)

destination_conn_url = URL.create(
    "mssql+pyodbc",
    query={"odbc_connect": "DRIVER={ODBC Driver 17 for SQL Server};"
                            "SERVER=WADINFWWDDV01;"
                            "DATABASE=WAD_STG_Integration;"
                            "Trusted_Connection=yes;"}
)

# Step 1: Extract and Insert Data in Batches with Detailed Logging and Comparison
def extract_and_insert_data(batch_size=60_000):
    start_time = time.time()
    source_engine = create_engine(source_conn_url)
    destination_engine = create_engine(destination_conn_url, fast_executemany=True)

    query = "SELECT * FROM [dbo].[vw_DSAT_HBE_BSA]"
    total_rows = 0
    cumulative_rows = 0
    batch_count = 0
    
    with source_engine.connect() as source_conn:
        total_rows = pd.read_sql("SELECT COUNT(*) FROM [dbo].[vw_DSAT_HBE_BSA]", source_conn).iloc[0, 0]
    
    logger.info(f"Starting extraction of {total_rows} rows from source")
    
    with source_engine.connect() as source_conn, destination_engine.connect() as dest_conn:
        for chunk in pd.read_sql(query, source_conn, chunksize=batch_size):
            batch_count += 1

            # Deduplication
            initial_chunk_size = len(chunk)
            chunk = chunk.drop_duplicates(subset=['TicketId'])
            duplicates_removed = initial_chunk_size - len(chunk)
            logger.info(f"Batch {batch_count}: Retrieved {initial_chunk_size} rows, removed {duplicates_removed} duplicates, inserting {len(chunk)} rows.")

            # Convert columns to strings and replace NaNs for compatibility
            chunk = chunk.astype(str).replace([np.nan, 'NaN', 'None', np.inf, -np.inf], '')

            # Insert chunk into destination
            chunk.to_sql(
                'vw_DSAT_HBE_BSA',
                schema='LZ_Capital',
                con=dest_conn,
                if_exists='append',
                index=False,
                chunksize=5000
            )

            cumulative_rows += len(chunk)
            target_row_count_query = "SELECT COUNT(*) FROM [LZ_Capital].[vw_DSAT_HBE_BSA]"
            target_row_count = pd.read_sql(target_row_count_query, dest_conn).iloc[0, 0]
            logger.info(f"Batch {batch_count}: Inserted {len(chunk)} rows. Cumulative processed: {cumulative_rows}/{total_rows}. Target row count: {target_row_count}")

    # Deduplication in target table
    deduplication_query = """
    WITH cte AS (
        SELECT TicketId,
               ROW_NUMBER() OVER (PARTITION BY TicketId ORDER BY (SELECT NULL)) AS row_num
        FROM [LZ_Capital].[vw_DSAT_HBE_BSA]
    )
    DELETE FROM [LZ_Capital].[vw_DSAT_HBE_BSA]
    WHERE TicketId IN (
        SELECT TicketId FROM cte WHERE row_num > 1
    );
    """
    with destination_engine.connect() as dest_conn:
        logger.info("Removing duplicates from target table.")
        result = dest_conn.execute(text(deduplication_query))
        logger.info(f"Deduplication complete. Rows removed: {result.rowcount if result.rowcount is not None else 'unknown'}")

    # Reopen connection for final row count after deduplication
    with destination_engine.connect() as dest_conn:
        final_target_row_count = pd.read_sql(target_row_count_query, dest_conn).iloc[0, 0]
        logger.info(f"Final row count in target table after deduplication: {final_target_row_count}")

    total_extraction_time = time.time() - start_time
    logger.info(f"Extraction and insertion complete. Total rows processed: {cumulative_rows}")
    logger.info(f"Total time: {total_extraction_time:.2f} seconds")

# Main function
def main():
    logger.info("ETL Job Started")
    extract_and_insert_data()
    logger.info("ETL Job Completed")

if __name__ == "__main__":
    main()
