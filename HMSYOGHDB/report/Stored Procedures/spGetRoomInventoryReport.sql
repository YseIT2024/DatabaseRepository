CREATE PROCEDURE [report].[spGetRoomInventoryReport]
(
 @FromDate datetime,
 @ToDate datetime,
 @LocationId Int=1
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
DECLARE @TempDates table (startdate date);

--SET @FromDate='15/Oct/2023'
--SET @ToDate='20/Oct/2023'
DECLARE @Cols  AS NVARCHAR(MAX)='';
DECLARE @QueryInventoryReport  AS NVARCHAR(MAX)='';

DECLARE @DayCount int = (SELECT DATEDIFF(day, @FromDate,@ToDate))+1;

create table #tempTable_Report
(
   RoomType NVARCHAR(150),
   --TotalCount INT,
   StandardInventory INT,
   TotalInventory INT,
   Booked INT,
   Available INT,
   BookingMode NVARCHAR(150),
   Dates NVARCHAR(150),
   DayWiseBookCount INT,
   Total INT
)
 
DECLARE @tempTable_Report_Temp TABLE 
(
   RoomType NVARCHAR(150),
   --TotalCount INT,
   StandardInventory INT,
   TotalInventory INT,
   Booked INT,
   Available INT,
   BookingMode NVARCHAR(150),
   Dates NVARCHAR(150),
   DayWiseBookCount INT,
   Total INT
)


DECLARE @SubCategoryName NVARCHAR(150);
DECLARE @TotalCount INT;
DECLARE @Booked INT;
DECLARE @Available INT;
DECLARE @BookingModeName NVARCHAR(150);
DECLARE @AvailableRoomCount INT;
DECLARE @DayWiseBookCount INT;
DECLARE @Total INT;

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
--select * from @TempDates
 

DECLARE @roomType varchar(150);
DECLARE myCursorRoomType CURSOR FOR SELECT DISTINCT rt.SubCategoryID RoomTypeID FROM Products.SubCategory rt  WHERE   rt.IsActive=1 AND rt.CategoryID=1
OPEN myCursorRoomType;
FETCH NEXT FROM myCursorRoomType INTO @roomType;
WHILE @@FETCH_STATUS = 0
BEGIN

SELECT  @SubCategoryName=Name
		--@TotalCount=ISNULL(TotalInventory,0)
		FROM Products.SubCategory WHERE SubCategoryID=@roomType

SET @TotalCount=(SELECT count(RoomNo) FROM Products.Room WHERE SubCategoryID=@roomType AND IsActive=1)
SET @AvailableRoomCount=0--(select count(RoomNo) from Products.Room where SubCategoryID=@roomType and RoomStatusID=1 and IsActive=1) -- Vacant -	Available for booking


				DECLARE @ReservationModeID INT;
				DECLARE myCursor_ReservationMode CURSOR FOR SELECT ReservationModeID FROM [reservation].[ReservationMode]
				OPEN myCursor_ReservationMode;
				FETCH NEXT FROM myCursor_ReservationMode INTO @ReservationModeID;
				WHILE @@FETCH_STATUS = 0
				BEGIN

				SET @BookingModeName=(SELECT ReservationMode FROM [reservation].[ReservationMode] WHERE ReservationModeID=@ReservationModeID)

				SET @Total=0
							DECLARE @startdate Date;
							DECLARE myCursor CURSOR FOR select startdate from @TempDates
							OPEN myCursor;
							FETCH NEXT FROM myCursor INTO @startdate;
							WHILE @@FETCH_STATUS = 0
							BEGIN
											
								SET @DayWiseBookCount=(select count(*) from reservation.Reservation
														where ReservationModeID=@ReservationModeID
														and format(ExpectedCheckIn, 'dd/MM/yyyy')=format(@startdate, 'dd/MM/yyyy') 
														and  ReservationStatusID in (1,3,12)
														and ReservationID in ((SELECT ReservationID FROM [reservation].ReservationDetails rd inner join Products.Item it on rd.ItemID = it.ItemID where SubCategoryID=@roomType)))

								 SET @Booked = (@Booked+@DayWiseBookCount);

							SET @Total=0--@Total+@DayWiseBookCount;
				
INSERT INTO @tempTable_Report_Temp(RoomType,StandardInventory,TotalInventory,Booked,Available,BookingMode,Dates,DayWiseBookCount,Total)
VALUES(@SubCategoryName,@TotalCount,@TotalCount*@DayCount , @Booked,@AvailableRoomCount,@BookingModeName,@startdate,@DayWiseBookCount,@Total);

--INSERT INTO #tempTable_Report(RoomType,StandardInventory,TotalInventory,Booked,Available,BookingMode,Dates,DayWiseBookCount,Total)
--VALUES(@SubCategoryName,@TotalCount,@TotalCount*@DayCount , @Booked,@AvailableRoomCount,@BookingModeName,@startdate,@DayWiseBookCount,@Total);




							FETCH NEXT FROM myCursor INTO @startdate;
							END
							CLOSE myCursor;
							DEALLOCATE myCursor;



				FETCH NEXT FROM myCursor_ReservationMode INTO @ReservationModeID;
				END
				CLOSE myCursor_ReservationMode;
				DEALLOCATE myCursor_ReservationMode;

				INSERT INTO #tempTable_Report(RoomType,StandardInventory,TotalInventory,Booked,Available,BookingMode,Dates,DayWiseBookCount,Total)
(SELECT 
RoomType,
StandardInventory,
TotalInventory,
(SELECT SUM(DayWiseBookCount) FROM @tempTable_Report_Temp),
TotalInventory-(SELECT SUM(DayWiseBookCount) FROM @tempTable_Report_Temp),
BookingMode,
Dates,
DayWiseBookCount,
(SELECT SUM(DayWiseBookCount) FROM @tempTable_Report_Temp)
FROM @tempTable_Report_Temp);

		DELETE FROM @tempTable_Report_Temp;
		
  set @Booked=0;

FETCH NEXT FROM myCursorRoomType INTO @roomType;
END
CLOSE myCursorRoomType;
DEALLOCATE myCursorRoomType;
-- Cursor End



SELECT @Cols = @Cols + QUOTENAME(startdate) + ',' FROM (select distinct FORMAT(startdate,'yyyy-MM-dd') as startdate from @TempDates ) as tmp


		SELECT @Cols = substring(@Cols, 0, len(@Cols)) --trim "," at end
--print @Cols
SET @QueryInventoryReport ='SELECT  * FROM (SELECT RoomType as [Room Type],StandardInventory as [Standard Inventory],TotalInventory as [Total Inventory],Booked,Available,BookingMode as [Booking Mode],Dates,DayWiseBookCount FROM #tempTable_Report) res
PIVOT (
  max(DayWiseBookCount)
  FOR Dates IN (' + @Cols + ')
) AS PivotTable '


execute(@QueryInventoryReport)
--select * from #tempTable_Report  -- select query
drop table #tempTable_Report

END