use CapitalManagementProduction
   SET NOCOUNT ON
   DECLARE  @SchemaName NVARCHAR(100) = 'dbo'


   SELECT 'ALTER TABLE ' + QUOTENAME(SCHEMA_NAME(t.schema_id))
   +'.'+ QUOTENAME(OBJECT_NAME(s.parent_object_id))
   + ' DROP CONSTRAINT ' +  QUOTENAME(s.name)   
   FROM sys.foreign_keys s
   JOIN sys.tables t on s.parent_object_id = t.object_id
   JOIN sys.tables t2 on s.referenced_object_id = t2.object_id
    WHERE t2.schema_id = SCHEMA_ID(@SchemaName)

    SELECT 'DROP ' +
                    CASE WHEN type IN ('P','PC') THEN 'PROCEDURE'
                         WHEN type =  'U' THEN 'TABLE'
                         WHEN type IN ('IF','TF','FN') THEN 'FUNCTION'
                         WHEN type = 'V' THEN 'VIEW'
                     END +
                   ' ' +  QUOTENAME(SCHEMA_NAME(schema_id))+'.'+QUOTENAME(name)  
                   FROM sys.objects
             WHERE schema_id = SCHEMA_ID(@SchemaName)
    AND type IN('P','PC','U','IF','TF','FN','V')
    ORDER BY  CASE WHEN type IN ('P','PC') THEN 4
                         WHEN type =  'U' THEN 3
                         WHEN type IN ('IF','TF','FN') THEN 1
                         WHEN type = 'V' THEN 2
                       END


  SELECT 'DROP XML SCHEMA COLLECTION '
  + QUOTENAME(SCHEMA_NAME(schema_id))+'.'+QUOTENAME(name)
  FROM sys.xml_schema_collections
  WHERE schema_id = SCHEMA_ID(@SchemaName)

  SELECT 'DROP SCHEMA ' + QUOTENAME(@SchemaName)

