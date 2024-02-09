
CREATE PROCEDURE [shift].[spGetShiftAllocationPageLoadData]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [JobTitleID], [JobTitle]
	FROM [shift].[JobTitle]

	SELECT [ShiftID], ss.[Shift] [ShiftType]
	,CONVERT(varchar, ss.StartAt, 100) + ' - ' + CONVERT(varchar, ss.EndAt, 100) [Duration]	
	FROM [shift].[Shift] ss	

	SELECT ShiftID, 0 ShiftStatusID, Shift+ ' (' + CONVERT(varchar, StartAt, 100) +' - '+ CONVERT(varchar, EndAt, 100) +')' DisplayText FROM [shift].[Shift]
	UNION
	SELECT 0 ShiftID, ShiftStatusID, ShiftStatus DisplayText FROM [shift].[Status] WHERE ShiftStatusID = 2
END










