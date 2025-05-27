CREATE FUNCTION [ProjApproval].[ufn1_IRR]
  (
   @s0 DECIMAL(30,10),
   @s1 DECIMAL(30,10),
   @s2 DECIMAL(30,10),
   @s3 DECIMAL(30,10),
   @s4 DECIMAL(30,10),
   @s5 DECIMAL(30,10),
   @s6 DECIMAL(30,10),
   @s7 DECIMAL(30,10),
   @s8 DECIMAL(30,10),
   @s9 DECIMAL(30,10),
   @s10 DECIMAL(30,10),
   @s11 DECIMAL(30,10),
   @s12 DECIMAL(30,10),
   @s13 DECIMAL(30,10),
   @s14 DECIMAL(30,10),
   @s15 DECIMAL(30,10),
   @s16 DECIMAL(30,10),
   @s17 DECIMAL(30,10),
   @s18 DECIMAL(30,10),
   @s19 DECIMAL(30,10),
   @s20 DECIMAL(30,10),
   @guess DECIMAL(30,10)
  )
RETURNS DECIMAL(30, 10)
AS 
  BEGIN
    DECLARE @t_IDs TABLE (
        id INT IDENTITY(0, 1),
        value DECIMAL(30, 10)
    )
    Declare @NPV DECIMAL(30, 10)

    INSERT INTO @t_IDs (value) values (@s0);
    INSERT INTO @t_IDs (value) values (@s1);
    INSERT INTO @t_IDs (value) values (@s2);
    INSERT INTO @t_IDs (value) values (@s3);
    INSERT INTO @t_IDs (value) values (@s4);
    INSERT INTO @t_IDs (value) values (@s5);
    INSERT INTO @t_IDs (value) values (@s6);
    INSERT INTO @t_IDs (value) values (@s7);
    INSERT INTO @t_IDs (value) values (@s8);
    INSERT INTO @t_IDs (value) values (@s9);
    INSERT INTO @t_IDs (value) values (@s10);
    INSERT INTO @t_IDs (value) values (@s11);
    INSERT INTO @t_IDs (value) values (@s12);
    INSERT INTO @t_IDs (value) values (@s13);
    INSERT INTO @t_IDs (value) values (@s14);
    INSERT INTO @t_IDs (value) values (@s15);
    INSERT INTO @t_IDs (value) values (@s16);
    INSERT INTO @t_IDs (value) values (@s17);
    INSERT INTO @t_IDs (value) values (@s18);
    INSERT INTO @t_IDs (value) values (@s19);
    INSERT INTO @t_IDs (value) values (@s20);

    SET @guess = CASE WHEN ISNULL(@guess, 0) <= 0 THEN 0.00001 ELSE @guess END

    SELECT @NPV = SUM(value / POWER(1 + @guess, id)) FROM @t_IDs
    WHILE @NPV > 0 
      BEGIN
        SET @guess = @guess + 0.00001
        SELECT @NPV = SUM(value / POWER(1 + @guess, id)) FROM @t_IDs
      END
    RETURN @guess
  END