
CREATE FUNCTION [dbo].[CalcXIRR]
(
    @Sample XIRRTable READONLY,
    @Rate DECIMAL(19, 9) = 0.1
)
RETURNS DECIMAL(38, 9)
AS
BEGIN
    DECLARE @X DECIMAL(19, 9) = 0.0,
    @X0 DECIMAL(19, 9) = 0.1,
    @f DECIMAL(19, 9) = 0.0,
    @fbar DECIMAL(19, 9) = 0.0,
    @i TINYINT = 0,
    @found TINYINT = 0

IF @Rate IS NULL
    SET @Rate = 0.1

SET @X0 = @Rate

WHILE @i < 100
    BEGIN
        SELECT  @f = 0.0,
            @fbar = 0.0

        SELECT      @f = @f + value * POWER(1 + @X0, (-theDelta / 365.0E)),
        @fbar = @fbar - theDelta / 365.0E * value * POWER(1 + @X0, (-theDelta / 365.0E - 1))
        FROM    (
                SELECT  Value,
                    DATEDIFF(DAY, MIN(date) OVER (), date) AS theDelta
                FROM    @Sample
            ) AS d

        SET @X = @X0 - @f / @fbar

        If ABS(@X - @X0) < 0.00000001
        BEGIN
           SET @found = 1
           BREAK;
        END

        SET @X0 = @X
        SET @i += 1
   END

If @found = 1
    RETURN  @X

RETURN NULL
END