CREATE PROCEDURE [report].[spGetMonthWiseReport]
(
	 @FromDate datetime,
	 @ToDate datetime
)
AS
BEGIN

	SET NOCOUNT ON;

	
	DECLARE @TempDates table (startdate date);
	DECLARE @QueryReservationStatus AS NVARCHAR(MAX);
	DECLARE @QueryRoomType AS NVARCHAR(MAX);
	DECLARE @Cols  AS NVARCHAR(MAX)='';

	DECLARE @AvailableRoomCount INT;
	DECLARE @CheckInCount INT;
	DECLARE @InHouseCount INT;
	DECLARE @BlockCount INT;
	DECLARE @TotalCount INT;
	DECLARE @OccupancyPercentageTotal INT;
	DECLARE @OccupancyCount INT;
	DECLARE @AvailableRoomCountDec DECIMAL(18,2);
	DECLARE @OccupancyCountDec DECIMAL(18,2);
	DECLARE @OccupancyPercentage DECIMAL(18,2);

--SET @FromDate='01/Aug/2023'
--SET @ToDate='31/Aug/2023'

create table #tempTableRoomStaus
(
   SNo INT,
   ReservationStatus NVARCHAR(150),
   Dates NVARCHAR(150),
   StatusCount INT
)

create table #tempTableRoomType
(
   RoomType NVARCHAR(150),
   Dates NVARCHAR(150),
   StatusCount INT
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

-- Cursor Start
	DECLARE @startdate Date;
	DECLARE myCursor CURSOR FOR select startdate from @TempDates
	OPEN myCursor;
	FETCH NEXT FROM myCursor INTO @startdate;
	WHILE @@FETCH_STATUS = 0
	BEGIN

				SET @AvailableRoomCount=(select [report].[fnGetAvailableRoom](CONVERT(datetime, @startdate, 103),CONVERT(datetime, @startdate, 103)))
				SET @CheckInCount =(select [report].[fnGetExpectedCheckIn](CONVERT(datetime, @startdate, 103),CONVERT(datetime, @startdate, 103)))
				SET @InHouseCount =(select [report].[fnGetStayOnInHouse](CONVERT(datetime, @startdate, 103),CONVERT(datetime, @startdate, 103)))
				SET @BlockCount =(select [report].[fnGetMaintBlock](CONVERT(datetime, @startdate, 103),CONVERT(datetime, @startdate, 103)))
				SET @TotalCount =ISNULL(@AvailableRoomCount,0)-(ISNULL(@CheckInCount,0)+ISNULL(@InHouseCount,0)+ISNULL(@BlockCount,0))
				SET @OccupancyCount=(select [report].[fnGetOccupancy](CONVERT(datetime, @startdate, 103),CONVERT(datetime, @startdate, 103)))
				
				SET @AvailableRoomCountDec=CONVERT(DECIMAL(18,2),ISNULL(@AvailableRoomCount,0))  
				SET @OccupancyCountDec=CONVERT(DECIMAL(18,2),ISNULL(@OccupancyCount,0))

				IF(@OccupancyCount !=NULL OR @OccupancyCount !='')
					 SET @OccupancyPercentage=@OccupancyCountDec/@AvailableRoomCountDec*100;
				ELSE
					SET @OccupancyPercentage =0


				SET @OccupancyPercentageTotal=CAST(ROUND(@OccupancyPercentage,0) as INTEGER);

				INSERT INTO #tempTableRoomStaus(SNo,ReservationStatus,Dates,StatusCount)values
				(1,'Available Room',FORMAT(@startdate,'yyyy-MM-dd'),@AvailableRoomCount),
				(2,'Expected Check-In',FORMAT(@startdate,'yyyy-MM-dd'),@CheckInCount),
				(3,'Stay On In-House',FORMAT(@startdate,'yyyy-MM-dd'),@InHouseCount),
				(4,'Occupancy',FORMAT(@startdate,'yyyy-MM-dd'),@OccupancyCount),
				(5,'Expected Check-Out',FORMAT(@startdate,'yyyy-MM-dd'),(select [report].[fnGetExpectedCheckOut](CONVERT(datetime, @startdate, 103),CONVERT(datetime, @startdate, 103)))),
				(6,'Management Block',FORMAT(@startdate,'yyyy-MM-dd'),''),
				(7,'Maintenance Block',FORMAT(@startdate,'yyyy-MM-dd'),@BlockCount),
				(8,'Position',FORMAT(@startdate,'yyyy-MM-dd'),@TotalCount),
				(9,'Wait List',FORMAT(@startdate,'yyyy-MM-dd'),(select [report].[fnGetWaitList](CONVERT(datetime, @startdate, 103),CONVERT(datetime, @startdate, 103)))),
				(10,'Occupancy %',FORMAT(@startdate,'yyyy-MM-dd'),@OccupancyPercentageTotal);

   --  Nested Cursor Start
				DECLARE @roomType varchar(150);
				DECLARE myCursorRoomType CURSOR FOR SELECT DISTINCT rt.SubCategoryID RoomTypeID FROM Products.SubCategory rt  WHERE   rt.IsActive=1 AND rt.CategoryID=1
				OPEN myCursorRoomType;
				FETCH NEXT FROM myCursorRoomType INTO @roomType;
				WHILE @@FETCH_STATUS = 0
				BEGIN
				  INSERT INTO #tempTableRoomType(RoomType,Dates,StatusCount)values
					((SELECT Name FROM Products.SubCategory WHERE SubCategoryID=@roomType),FORMAT(@startdate,'yyyy-MM-dd'),(select [report].[fnRoomTypePosition](CONVERT(datetime, @startdate, 103),@roomType)))
				FETCH NEXT FROM myCursorRoomType INTO @roomType;
				END
				CLOSE myCursorRoomType;
				DEALLOCATE myCursorRoomType;
  --  Nested Cursor  End
		FETCH NEXT FROM myCursor INTO @startdate;
		END
		CLOSE myCursor;
		DEALLOCATE myCursor;
-- Cursor End
--select * from #tempTableRoomStaus  -- select query
--select * from #tempTableRoomType  -- select query





		SELECT @Cols = @Cols + QUOTENAME(startdate) + ',' FROM (select distinct FORMAT(startdate,'yyyy-MM-dd') as startdate from @TempDates ) as tmp


		SELECT @Cols = substring(@Cols, 0, len(@Cols)) --trim "," at end
--print @Cols
SET @QueryReservationStatus ='SELECT  * FROM (SELECT SNo,ReservationStatus,Dates,StatusCount FROM #tempTableRoomStaus) res
PIVOT (
  sum(StatusCount)
  FOR Dates IN (' + @Cols + ')
) AS PivotTable '
SET @QueryRoomType ='SELECT  * FROM (SELECT RoomType,Dates,StatusCount FROM #tempTableRoomType) res
PIVOT (
  sum(StatusCount)
  FOR Dates IN (' + @Cols + ')
) AS PivotTable '

execute(@QueryReservationStatus)
execute(@QueryRoomType)

drop table #tempTableRoomStaus
drop table #tempTableRoomType

   
END

