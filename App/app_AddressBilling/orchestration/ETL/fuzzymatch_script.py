# app_AddressBilling/orchestration/ETL/fuzzymatch_script.py

import os
import sys
import time
import logging
import warnings
import numpy as np
import pandas as pd
import psutil

from sqlalchemy import create_engine, text
from odbc import odbc_read, odbc_write, _get_server_and_db
from process_raw_addresses import clean_addresses, parse_addresses

warnings.simplefilter('ignore', category=FutureWarning)

script_dir = os.path.dirname(os.path.abspath(__file__))
log_filename = 'Fuzzymatch_Script.log'
log_file_path = os.path.join(script_dir, log_filename)

logging.basicConfig(
    filename=log_file_path,
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

print(f"Log file is being written to: {log_file_path}")
lock_file_path = os.path.join(script_dir, "fuzzymatch_script.lock")

def check_pid_still_running(pid):
    try:
        return psutil.pid_exists(pid)
    except:
        return False

def already_running_check():
    if os.path.exists(lock_file_path):
        try:
            with open(lock_file_path, 'r') as f:
                existing_pid_str = f.read().strip()
            existing_pid = int(existing_pid_str)
        except:
            existing_pid = None

        if existing_pid and check_pid_still_running(existing_pid):
            logging.info(f"Lock file with active PID={existing_pid}. Exiting.")
            print(f"Already running (pid={existing_pid}). Exiting.")
            sys.exit(0)
        else:
            logging.info("Stale lock file found. Removing => creating new.")
            os.remove(lock_file_path)

    with open(lock_file_path, 'w') as f:
        f.write(str(os.getpid()))
    logging.info(f"Lock file created for PID={os.getpid()}.")

def remove_lock_file():
    if os.path.exists(lock_file_path):
        os.remove(lock_file_path)
        logging.info("Lock file removed.")

def timed_execution(func, message, *args, **kwargs):
    start = time.time()
    result = func(*args, **kwargs)
    elapsed = (time.time() - start)/60.0
    logging.info(f"{message} {func.__name__.upper()}: {elapsed:.2f} min")
    return result

def get_sqlalchemy_engine():
    server, database = _get_server_and_db()
    driver = "ODBC Driver 17 for SQL Server"
    conn_str = f"mssql+pyodbc://@{server}/{database}?driver={driver}&Trusted_Connection=yes"
    return create_engine(conn_str, echo=False)

def archive_fuzzymatch_records():
    engine = get_sqlalchemy_engine()
    logging.info("Archiving from Fuzzymatch_Output => Fuzzymatch_Output_Archive...")
    with engine.begin() as conn:
        conn.execute(text("""
            INSERT INTO ADDRESS_BILLING.Fuzzymatch_Output_Archive
            SELECT * FROM ADDRESS_BILLING.Fuzzymatch_Output
        """))
        conn.execute(text("DELETE FROM ADDRESS_BILLING.Fuzzymatch_Output"))
    logging.info("Fuzzymatch_Output archive step done.")

def archive_ui_lz_records():
    engine = get_sqlalchemy_engine()
    logging.info("Archiving 'done' rows from UI_LZ => UI_LZ_Archive...")
    with engine.begin() as conn:
        done_batches = conn.execute(text("""
            SELECT DISTINCT batch_id
            FROM ADDRESS_BILLING.UI_LZ
            WHERE process_status='done'
        """)).fetchall()
        done_batches = [row[0] for row in done_batches]

    if not done_batches:
        logging.info("No 'done' rows found in UI_LZ => nothing to archive.")
        return

    with engine.begin() as conn:
        for b in done_batches:
            conn.execute(text("""
                INSERT INTO ADDRESS_BILLING.UI_LZ_Archive (
                    [user_def_row_ID],
                    [Address1],
                    [Address2],
                    [City],
                    [Zip],
                    [State],
                    [Country],
                    [DtmStamp],
                    [ingestion_timestamp],
                    [user_name],
                    [user_corp],
                    [batch_id],
                    [user_email],
                    [process_status]
                )
                SELECT
                    [user_def_row_ID],
                    [Address1],
                    [Address2],
                    [City],
                    [Zip],
                    [State],
                    [Country],
                    [DtmStamp],
                    [ingestion_timestamp],
                    [user_name],
                    [user_corp],
                    [batch_id],
                    [user_email],
                    [process_status]
                FROM ADDRESS_BILLING.UI_LZ
                WHERE process_status='done'
                  AND batch_id = :b
            """), {"b": b})
            conn.execute(text("""
                DELETE FROM ADDRESS_BILLING.UI_LZ
                WHERE process_status='done'
                  AND batch_id = :b
            """), {"b": b})

    logging.info("UI_LZ archiving step complete.")

def send_fuzzymatch_completion_email(batch_id, user_email):
    if not user_email:
        logging.info("No user_email => skipping completion email.")
        return

    hostname = os.environ.get('COMPUTERNAME','').upper()
    if hostname.endswith('DDV01'):
        base_url = "https://stg-wad.ftr.com"
    else:
        base_url = "https://wad.ftr.com"

    link = f"{base_url}/show_fuzzymatch_results/{batch_id}"
    subject = f"Fuzzymatch Complete for Batch {batch_id}"
    body = (
        f"Hello,\n\n"
        f"Your fuzzymatch & billing data for batch {batch_id} is ready.\n"
        f"Check:\n{link}\n\n"
        f"Regards,\nWholesale Team"
    )
    from_addr = "WAD@ftr.com"
    to_addr = user_email

    import smtplib
    from email.mime.text import MIMEText
    from email.mime.multipart import MIMEMultipart

    msg = MIMEMultipart()
    msg["Subject"] = subject
    msg["From"] = from_addr
    msg["To"] = to_addr
    msg.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP("MailRelay.corp.pvt", 25) as smtp:
            smtp.send_message(msg)
        logging.info(f"Sent fuzzymatch completion email to {user_email} for batch {batch_id}")
    except Exception as ex:
        logging.error(f"Failed sending completion email: {ex}")

def get_user_email_for_batch(batch_id):
    engine = get_sqlalchemy_engine()
    with engine.begin() as conn:
        row = conn.execute(text("""
            SELECT TOP 1 user_email
            FROM ADDRESS_BILLING.UI_LZ
            WHERE batch_id=:b
            ORDER BY ingestion_timestamp DESC
        """), {"b": batch_id}).fetchone()
        if row and row[0]:
            return row[0]
    return ""

def run_fuzzymatch():
    logging.info("run_fuzzymatch() started.")
    # read pending
    target_query = """
    SELECT *
    FROM ADDRESS_BILLING.UI_LZ
    WHERE process_status='pending'
    ORDER BY ID;
    """
    target0 = timed_execution(
        odbc_read, "UI_LZ pending =>",
        schema='ADDRESS_BILLING',
        table='UI_LZ',
        custom_query=target_query
    )
    if target0.empty:
        logging.info("No pending rows => exit.")
        print("No pending addresses.")
        return

    # read master
    source = timed_execution(
        odbc_read, "Master =>",
        schema='ADDRESS_BILLING',
        table='ADDR_BILLING_MASTER'
    )
    if source.empty:
        logging.info("Master table empty => exit.")
        return

    # prep
    target0["ADDRESS"] = target0["Address1"]
    target0["CITY"]    = target0["City"]
    target0["STATE"]   = target0["State"]
    target0["ZIP"] = target0["Zip"].str.extract(r'(\d+)', expand=False).str[:5]
    target0["ZIP"] = np.where(
        (target0["STATE"]=="CT") & (target0["ZIP"].str.len()==4),
        "0"+target0["ZIP"],
        target0["ZIP"]
    )

    df_L, df_R = timed_execution(clean_addresses, "clean_addresses =>", target0, source)
    df_match = timed_execution(parse_addresses, "parse_addresses =>",
        df_L[["ADDRESS","CITY","STATE","ZIP","full_address","index"]].copy(),
        df_R[["ADDRESS","CITY","STATE","ZIP","full_address","index","PRICING_TIER"]].copy()
    )

    df_match["EXACT_MATCH"] = (df_match["full_address_l"] == df_match["full_address_r"])
    df_match["ZIP_MATCH"]   = (df_match["ZIP_l"] == df_match["ZIP_r"])
    df_match["POST_MATCH"]  = (df_match["StreetNamePostDirectional_l"] == df_match["StreetNamePostDirectional_r"])

    df_match2 = df_match.sort_values(
        ["index_l","EXACT_MATCH","ZIP_MATCH","POST_MATCH","PRICING_TIER_r"],
        ascending=[True,False,False,False,True]
    ).drop_duplicates(["index_l"], keep='first')

    df_L = df_L.rename(columns={"index":"index_l"})
    df_R = df_R.rename(columns={"index":"index_r"})

    df_merge = df_match2[["index_l","index_r"]] \
        .merge(df_L,on="index_l",how="left") \
        .merge(df_R,on="index_r",how="left")

    df_merge["ADDRESS"] = df_merge["ADDRESS_y"].str.upper()
    df_merge["CITY"]    = df_merge["CITY_y"].str.upper()
    df_merge["STATE"]   = df_merge["STATE_y"].str.upper()
    df_merge["ZIP"]     = df_merge["ZIP_y"]

    # leftover unmatched
    Lmerged_df = pd.merge(
        df_L, df_match2[["index_l"]], on="index_l", how="left", indicator=True
    )
    newL_rows = Lmerged_df[Lmerged_df['_merge']=='left_only'].drop(columns=['_merge','full_address'])

    df_final = pd.concat([df_merge, newL_rows], ignore_index=True)
    df_final2 = df_final[[
        'batch_id','ID','ingestion_timestamp','user_def_row_ID',
        'Address1','ADDRESS_y','City','CITY_y','State','STATE_y','Zip','ZIP_y',
        'UniqueID','PRICING_TIER','LIT','EthernetLit','SWC',
        'WIRELINE_ETH','WIRELESS_ETH','WHSL_DIA','BUS_DIA','BB',
        'WAVELENGTH','TDM','SONET','VOICE','COLLO'
    ]].sort_values("ID").replace({None: np.nan, 'None': np.nan})

    df_final2.columns = [
        'batch_id','ID','ingestion_timestamp','user_def_row_ID',
        'Input_Address','Matched_Address','Input_City','Matched_City',
        'Input_State','Matched_State','Input_Zip','Matched_Zip',
        'BLL_UniqueID','PRICING_TIER','LIT','EthernetLit','SWC',
        'WIRELINE_ETH','WIRELESS_ETH','WHSL_DIA','BUS_DIA','BB',
        'WAVELENGTH','TDM','SONET','VOICE','COLLO'
    ]

    timed_execution(
        odbc_write, "writing => Fuzzymatch_Output",
        df_final2,
        schema='ADDRESS_BILLING',
        table='Fuzzymatch_Output',
        exists='append'
    )

    done_batches = df_final2['batch_id'].dropna().unique().tolist()
    if done_batches:
        engine = get_sqlalchemy_engine()
        with engine.begin() as conn:
            for b in done_batches:
                conn.execute(text("""
                    UPDATE ADDRESS_BILLING.UI_LZ
                    SET process_status='done'
                    WHERE batch_id=:b
                """), {"b": b})

    for b in done_batches:
        user_email = get_user_email_for_batch(b)
        send_fuzzymatch_completion_email(b, user_email)

    archive_fuzzymatch_records()
    archive_ui_lz_records()

    logging.info("run_fuzzymatch() finished.")
    print("Fuzzymatch + archiving steps completed.")

if __name__ == "__main__":
    try:
        already_running_check()
        run_fuzzymatch()
    finally:
        remove_lock_file()
