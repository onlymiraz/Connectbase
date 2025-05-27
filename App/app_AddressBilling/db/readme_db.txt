Key points:

Node → DB Mapping:

WADINFWWAPV02 → WAD_PRD_Integration
WADINFWWDDV01 → WAD_STG_Integration
If the node isn’t found, it defaults to 'Playground' (you can change this fallback if desired).
Creates the [addressbilling] schema if missing, then creates UI_LZ_Archive and Fuzzymatch_Output_Archive.

Skips ephemeral indexes on UI_LZ or Fuzzymatch_Output since those are truncated regularly.
Does create indexes on the archive tables, as that’s where data remains long-term.
Your existing “file ingestion” logic is still present (copying files, processing them, writing to a schema named LZ_Py).

We simply added a function create_addressbilling_objects() that runs before the ingestion, ensuring the addressbilling schema + archiving objects exist.
Everything is in one file. You can place it in app_AddressBilling/db/, then call python your_script.py from your CICD. The script:

Detects the hostname → picks the DB name
Creates AddressBilling DDL (schema + archives + indexes)
Does the file copying + ingestion into [LZ_Py].[…]
Summarizes results
Feel free to rename or reorganize if needed. Copy & paste the entire code below into a file such as app_AddressBilling/db/db_ingest_and_setup.py (or whatever you choose), then commit for your pipeline.