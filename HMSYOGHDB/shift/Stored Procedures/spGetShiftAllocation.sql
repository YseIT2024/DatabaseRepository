
CREATE PROCEDURE [shift].[spGetShiftAllocation] --'2019-12-01','2019-12-31',1
(
	@FromDate date,
	@ToDate date,
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromDateId int = CAST(FORMAT(@FromDate,'yyyyMMdd') as INT);
	DECLARE @ToDateId int = CAST(FORMAT(@ToDate,'yyyyMMdd') as INT);
	DECLARE @Cols AS VARCHAR(MAX);
	DECLARE @Query AS VARCHAR(MAX);

	CREATE TABLE temp_Shifts([Date] VARCHAR(20),[EmployeeIDNumber] INT, [Employee] VARCHAR(50),[ShiftType] VARCHAR(20),[Shift] VARCHAR(30),[JobTitle] VARCHAR(20),[Order] INT)

	INSERT temp_Shifts([Date],[EmployeeIDNumber],[Employee],[ShiftType],[Shift],[JobTitle],[Order])
	SELECT FORMAT(gd.[Date], 'dd-MMM-yyyy') [Date]	
	,p.EmployeeIDNumber [EmployeeIDNumber]
	,cd.FirstName +' '+ cd.LastName + ' (' + CAST(p.EmployeeIDNumber as varchar(10)) +')' [Employee]	
	,CASE WHEN sa.ShiftID IS NOT NULL THEN ss.[Shift] WHEN sa.ExceptionalShiftID IS NOT NULL THEN exss.[Description] ELSE '' END  [ShiftType]
	,CASE WHEN sa.ShiftID IS NOT NULL THEN (CONVERT(varchar, ss.StartAt, 100) +' - '+ CONVERT(varchar, ss.EndAt, 100))
		WHEN sa.ExceptionalShiftID IS NOT NULL THEN (CONVERT(varchar, exss.StartAt, 100) +' - '+ CONVERT(varchar, exss.EndAt, 100)) 
		ELSE '' END [Shift]
	,jt.JobTitle
	,ISNULL(ss.[DisplayOrder],33) [DisplayOrder]
	FROM [shift].[ShiftAllocation] sa
	INNER JOIN [shift].[JobTitle] jt ON sa.JobTitleID = jt.JobTitleID
	INNER JOIN [general].[Date] gd ON sa.DateID = gd.DateID
	LEFT JOIN [shift].[Shift] ss ON sa.ShiftID = ss.ShiftID	
	LEFT JOIN [Shift].[ExceptionalShift] exss ON sa.ExceptionalShiftID = exss.ExceptionalShiftID 
	INNER JOIN [person].[Employee] p ON sa.EmployeeID = p.EmployeeID
	INNER JOIN [contact].[Details] cd ON p.ContactID = cd.ContactID	
	WHERE sa.LocationID = @LocationID AND sa.DateID BETWEEN @FromDateId AND @ToDateId
	ORDER BY ss.[DisplayOrder]
	
	SELECT @Cols = COALESCE(@Cols +',','') + QUOTENAME([DATE])
	FROM 
	(
		SELECT FORMAT([Date],'dd-MMM-yyyy') [Date]  
		FROM [general].[Date] WHERE DateID BETWEEN @FromDateID AND @ToDateID
	) AS tab
	
	SET @Query = 'SELECT [Order],[JobTitle],[EmployeeIDNumber],[Employee],[ShiftType], ' + @Cols + ' FROM
				  (
					SELECT [Order],[JobTitle],[EmployeeIDNumber],[Employee],[ShiftType],[Shift],[Date]														
					FROM temp_Shifts
				  )x             
				  PIVOT 
				  (
					MAX([Shift])
					FOR [Date] IN (' + @Cols + ')
				  )p';         
    
	EXECUTE (@Query)

	DROP TABLE temp_Shifts  
END










