CREATE PROCEDURE  [Housekeeping].[sp_HousekeepingWeeklyScheduleReport] --'04-Sep-2023','04-Nov-2023'
(
	 @FromDate DATE,
	 @ToDate DATE
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @DynamicQuery AS NVARCHAR(MAX);                                            
	DECLARE @Cols AS NVARCHAR(MAX)='';
	DECLARE @TempDates table (startdate date);

	create table #tempTableWeeklyStatus 
			(
				ChecklistName NVARCHAR(150),
				ScheduleDay NVARCHAR(150),
				ScheduleDate NVARCHAR(150),
				Schedule INT
			)

;WITH cte (startdate)
	AS 
	(
	SELECT @FromDate AS startdate
	UNION ALL
	SELECT
	DATEADD(DAY, 1, startdate) AS startdate
	FROM cte
	WHERE startdate < @ToDate
	)
	INSERT INTO @TempDates SELECT c.startdate FROM cte c

--SELECT * FROM @TempDates;
 
			DECLARE @ChecklistId int;
			DECLARE myCursor CURSOR FOR select ChecklistId from [Housekeeping].[HKChecklist] WHERE IsActive=1
			OPEN myCursor;
			FETCH NEXT FROM myCursor INTO @ChecklistId;
			WHILE @@FETCH_STATUS = 0
			BEGIN
	 
		  --  Nested Cursor Start
				DECLARE @startdate DATE;
				DECLARE myCursorDates CURSOR FOR select startdate from @TempDates
				OPEN myCursorDates;
				FETCH NEXT FROM myCursorDates INTO @startdate;
				WHILE @@FETCH_STATUS = 0
				BEGIN
						INSERT INTO #tempTableWeeklyStatus(ChecklistName,ScheduleDate,Schedule,ScheduleDay)VALUES
						((select ChecklistName from [Housekeeping].[HKChecklist] where ChecklistId=@ChecklistId AND IsActive=1),
						--(SELECT CONCAT((SELECT @startdate),' ' ,DATENAME(WEEKDAY, @startdate))),
						(SELECT CONCAT((FORMAT(@startdate, 'yyyy-MM-dd')),' ' ,DATENAME(WEEKDAY, @startdate))),
						
						CASE WHEN 
							(SELECT COUNT(*) FROM [Housekeeping].[HKChecklistSchedule] HS
							INNER JOIN [Housekeeping].[HKChecklistScheduleDetails] HD ON HS.ChecklistScheduleId=HD.ChecklistScheduleId
							INNER JOIN [Housekeeping].[HKChecklist] CL ON HS.ChecklistId=CL.ChecklistId
							WHERE HS.ChecklistId=@ChecklistId AND --HS.Frequency='Weekly' AND
							--HD.ScheduleDate = @startdate
							FORMAT(HD.ScheduleDate, 'yyyy-MMM-dd')= FORMAT(@startdate, 'yyyy-MMM-dd')
							AND HD.IsActive=1 AND CL.IsActive=1) !=  0 
							THEN 1
						ELSE 0
						END, (SELECT @startdate))
						
				FETCH NEXT FROM myCursorDates INTO @startdate;
				END
				CLOSE myCursorDates;
				DEALLOCATE myCursorDates;
		  --  Nested Cursor  End

			FETCH NEXT FROM myCursor INTO @ChecklistId;
			END
			CLOSE myCursor;
			DEALLOCATE myCursor;

	--SELECT *
	--FROM (
	--	SELECT ChecklistName, ScheduleDate, Schedule
	--	FROM #tempTableWeeklyStatus
	--) AS res
	--PIVOT (
	--	MAX(Schedule)
	--	FOR ScheduleDate IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
	--) AS PivotTable;

 SELECT @Cols = @Cols + QUOTENAME(ScheduleDate) + ',' FROM (select distinct ScheduleDate as ScheduleDate from #tempTableWeeklyStatus) as tmp 
 SELECT @Cols = substring(@Cols, 0, len(@Cols)) --trim "," at end
 print @Cols

SET @DynamicQuery ='SELECT * FROM (SELECT ChecklistName, ScheduleDate, Schedule	FROM #tempTableWeeklyStatus) AS res
	PIVOT (
		MAX(Schedule)
		FOR ScheduleDate IN (' + @Cols + ')
	) AS PivotTabl'

execute(@DynamicQuery);
drop table #tempTableWeeklyStatus

SELECT CL.ChecklistName,  
		HD.[ScheduleDetailId],HD.[ChecklistScheduleId],HD.[ChecklistId],HD.[ScheduleDate],HD.[ScheduleFromTime]
       ,HD.[ScheduleToTime],HD.[StatusId],HD.[IsActive],HD.[CreatedBy],HD.[CreatedOn]
	   ,ST.AllocatedTo,ST.Supervisor, ST.AllocatedLocation,ST.AllocationId
	   ,(select FirstName + ' ' + LastName from  [contact].[Details] where ContactID=ST.[AllocatedTo]) as AllocatedName
	   ,(select FirstName + ' ' + LastName from  [contact].[Details] where ContactID=ST.[Supervisor]) as SupervisorName,
	  
	  HD.[ModifiedBy],HD.[ModifiedOn]
	--  SC.TaskCompletionId
  FROM [Housekeeping].[HKChecklistSchedule] HS
		INNER JOIN [Housekeeping].[HKChecklistScheduleDetails] HD ON HS.ChecklistScheduleId=HD.ChecklistScheduleId
		LEFT JOIN [Housekeeping].[ScheduleTaskAllocation] ST ON HD.ScheduleDetailId=ST.ScheduleDetailId		
		INNER JOIN [Housekeeping].[HKChecklist] CL ON HS.ChecklistId=CL.ChecklistId		
	--	Left join [Housekeeping].[ScheduleTaskCompletion] SC ON ST.AllocationId=SC.AllocationId
	--	 WHERE HD.ScheduleDate >= '2023-08-26' AND HD.ScheduleDate <= '2023-09-30' and HD.IsActive=1 
  WHERE HD.ScheduleDate >= @FromDate AND HD.ScheduleDate <= @ToDate and HD.IsActive=1  
  
END
