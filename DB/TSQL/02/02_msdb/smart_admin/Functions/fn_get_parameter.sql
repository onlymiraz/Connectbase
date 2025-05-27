﻿
CREATE   FUNCTION smart_admin.fn_get_parameter(@parameter_name NVARCHAR(128))
       RETURNS @t table
       (
              parameter_name       NVARCHAR(128),
              parameter_value      NVARCHAR(MAX)
       )
AS
BEGIN
       INSERT INTO @t
       SELECT parameter_name, parameter_value 
       FROM managed_backup.fn_get_parameter (@parameter_name)

       RETURN
END
