
CREATE FUNCTION [reservation].[fnGetStandardCheckOutTime]()
RETURNS VARCHAR(8)
AS
BEGIN
	RETURN (SELECT [StandardCheckOutTime] FROM [reservation].[StandardCheckInOutTime] WHERE [StandardCheckInOutTimeID] = 1)
END










