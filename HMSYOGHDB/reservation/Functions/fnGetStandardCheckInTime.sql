

CREATE FUNCTION [reservation].[fnGetStandardCheckInTime]()
RETURNS VARCHAR(8)
AS
BEGIN
	RETURN (SELECT [StandardCheckInTime] FROM [reservation].[StandardCheckInOutTime] WHERE [StandardCheckInOutTimeID] = 1)
END











