CREATE NONCLUSTERED INDEX [IX_Fuzzymatch_timestamp]
    ON [addressbilling].[Fuzzymatch_Output] ([ingestion_timestamp]);

CREATE NONCLUSTERED INDEX [IX_Fuzzymatch_state]
    ON [addressbilling].[Fuzzymatch_Output] ([Matched_State]);
