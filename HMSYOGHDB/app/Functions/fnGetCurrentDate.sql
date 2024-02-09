
CREATE FUNCTION [app].[fnGetCurrentDate]()
RETURNS int
AS
BEGIN
	RETURN CAST(FORMAT(GETDATE(),'yyyyMMdd') as int);
END
