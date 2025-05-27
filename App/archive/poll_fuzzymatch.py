# App/app_AddressBilling/poll_fuzzymatch.py
import time
import logging
import pyodbc
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from app_AddressBilling.fuzzymatch_script import run_fuzzymatch

"""
This script runs in a loop every 60 seconds:
1) Finds UI_LZ rows with process_status='pending'
2) Marks them 'in_progress'
3) Calls run_fuzzymatch(batch_id)
4) Marks them 'done'
5) Emails the user a link to fuzzymatch_powerbi_view
"""

logging.basicConfig(
    filename='poll_fuzzymatch.log',
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s'
)

DB_CONNECTION = (
    "DRIVER={SQL Server};"
    "SERVER=WADINFWWDDV01;"
    "DATABASE=Playground;"
    "Trusted_Connection=yes;"
)

def get_pending_batches():
    conn = pyodbc.connect(DB_CONNECTION)
    cursor = conn.cursor()
    sql = """
    SELECT DISTINCT batch_id, MAX(user_email)
    FROM addressbilling.UI_LZ
    WHERE process_status='pending'
    GROUP BY batch_id
    """
    rows = cursor.execute(sql).fetchall()
    conn.close()
    results = []
    for row in rows:
        if row[0]:
            results.append((row[0], row[1]))
    return results

def mark_in_progress(batch_id):
    conn = pyodbc.connect(DB_CONNECTION)
    cursor = conn.cursor()
    sql = """
    UPDATE addressbilling.UI_LZ
    SET process_status='in_progress'
    WHERE batch_id=?
    """
    cursor.execute(sql, batch_id)
    conn.commit()
    conn.close()

def mark_done(batch_id):
    conn = pyodbc.connect(DB_CONNECTION)
    cursor = conn.cursor()
    sql = """
    UPDATE addressbilling.UI_LZ
    SET process_status='done'
    WHERE batch_id=?
    """
    cursor.execute(sql, batch_id)
    conn.commit()
    conn.close()

def send_link_email(batch_id, user_email):
    if not user_email:
        logging.info(f"No user_email for batch_id={batch_id}, skipping email.")
        return
    link = f"https://stg-wad.ftr.com/fuzzymatch_powerbi_view?batch_id={batch_id}"
    subject = f"Fuzzymatch Results for Batch {batch_id}"
    body = (
        f"Hello,\n\n"
        f"Your fuzzymatch results are ready. View here:\n{link}\n\n"
        f"You can download Excel/CSV on that page.\n\n"
        f"Regards,\nTeam"
    )
    from_addr = "WAD@ftr.com"
    to_addr = user_email
    msg = MIMEMultipart()
    msg["Subject"] = subject
    msg["From"] = from_addr
    msg["To"] = to_addr
    msg.attach(MIMEText(body, "plain"))

    with smtplib.SMTP("MailRelay.corp.pvt", 25) as smtp:
        smtp.send_message(msg)
    logging.info(f"Emailed user {user_email} for batch_id={batch_id}")

def main_loop():
    logging.info("Starting fuzzymatch polling loop... Checking every 60s.")
    while True:
        try:
            pending = get_pending_batches()
            if pending:
                logging.info(f"Found {len(pending)} pending batch(es).")
                for (batch_id, user_email) in pending:
                    logging.info(f"Setting batch_id={batch_id} to in_progress.")
                    mark_in_progress(batch_id)
                    try:
                        run_fuzzymatch(batch_id)
                        mark_done(batch_id)
                        send_link_email(batch_id, user_email)
                    except Exception as e:
                        logging.exception(f"Error fuzzymatching batch {batch_id}: {e}")
                        # Optionally revert to 'pending' or 'error'
            else:
                logging.info("No pending batches found.")
        except Exception as ex:
            logging.exception(f"Main loop error: {ex}")

        # Wait 60 seconds
        time.sleep(60)

if __name__ == "__main__":
    main_loop()
