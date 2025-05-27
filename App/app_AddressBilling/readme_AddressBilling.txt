Below is a concise, end-to-end flow describing how the Address Billing system works, the tables involved, and which front-end pages expose them:

Upload Page (/upload -> upload.html)

User selects an Excel/CSV and provides an email.
The file is processed and columns are mapped to [addressbilling].[UI_LZ] (the “landing zone”).
UI_LZ.process_status defaults to 'pending'.
UI_LZ (Table in SQL Server)

Holds the raw, unprocessed addresses.
Key columns: batch_id, Address1, City, State, Zip, user_email, process_status.
Once uploaded, we can see them in the front-end:
/batch_history or the older /view_batch_data.html can show it.
Scheduled Task (the fuzzymatch orchestrator)

Windows Task Scheduler triggers fuzzymatch_script.py every X minutes (default was 5, changed to 30 or 60 if needed).
The script:
Looks for rows in UI_LZ with process_status='pending'.
Pulls the big master table [ADDRESS_BILLING].[ADDR_BILLING_MASTER].
Performs fuzzy matching.
Writes matched rows to [addressbilling].[Fuzzymatch_Output].
Updates UI_LZ.process_status='done'.
Sends an email to the user that results are ready.
Fuzzymatch_Output (Matched Results)

Rows for each address are enriched with matched city/state, pricing tier, etc.
The user can see these via:
/show_fuzzymatch_results/<batch_id>
/fuzzymatch_powerbi_view/<batch_id>
Or download CSV/Excel: /download_fuzzymatch_csv/<batch_id> and /download_fuzzymatch_excel/<batch_id>.
Archiving

After it populates Fuzzymatch_Output, the script moves them into [Fuzzymatch_Output_Archive].
Similarly, once UI_LZ.process_status='done', those rows are moved to [UI_LZ_Archive].
This keeps the “active” tables small.
Batch History (/batch_history)

Displays a combined list of UI_LZ + UI_LZ_Archive for all distinct batches, so the user can see status (“pending” vs. “done”), plus fuzzymatch row count.
Key SQL Objects:

[addressbilling].[UI_LZ] / [addressbilling].[UI_LZ_Archive] (Raw addresses)
[addressbilling].[Fuzzymatch_Output] / [addressbilling].[Fuzzymatch_Output_Archive] (Fuzzy results)
[ADDRESS_BILLING].[ADDR_BILLING_MASTER] in WAD_PRD_Integration (master reference for matching)
Front-End Pages:

/upload => upload.html (Upload addresses)
/mapping => mapping.html (Map columns)
/batch_history => batch_history.html
/show_fuzzymatch_results/<batch_id> => fuzzymatch_results.html
/fuzzymatch_powerbi_view/<batch_id> => fuzzymatch_powerbi_view.html
/show_fuzzymatch_summary/<batch_id> => fuzzymatch_summary.html
All of that is orchestrated by the routes in app_AddressBilling/routes.py and the main app.py.