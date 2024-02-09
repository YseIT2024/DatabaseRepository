
CREATE PROCEDURE [report].[spGetArrivalsStayoversDepartures] --5,'2021-03-22',1
(	
	@LocationID int,
	@Date date,
	@UserID int = NULL
)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tab table(ReservedStatus varchar(100), CheckIn varchar(11), CheckOut varchar(11), NoOfNights int, FolioNumber varchar(20), GuestName varchar(50), 
	ReservationStatus varchar(50), RoomNo int, Adults int, Children int, TodaysAction varchar(50))
	
	------------Arrivals-----------------
	INSERT INTO @tab
	(ReservedStatus,CheckIn,CheckOut,NoOfNights,FolioNumber,GuestName,ReservationStatus,RoomNo,Adults,Children,TodaysAction)
	SELECT CONCAT('Arrivals For ',Format(@Date,'dddd, MMMM d, yyyy'))
	,Format(vwr.ExpectedCheckIn,'dd-MMM-yyyy')
	,Format(vwr.ExpectedCheckOut,'dd-MMM-yyyy')
	,vwr.Nights 
	,vwr.FolioNumber
	,vwr.FullName
	,vwr.ReservationStatus
	,rm.RoomNo
	,vwr.Adults
	,vwr.Children
	,'Arrivals' [TodaysAction]
	FROM [reservation].[vwReservationDetails] vwr 
	INNER JOIN reservation.ReservedRoom rr ON vwr.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID	
	WHERE vwr.LocationID = @LocationID AND vwr.ReservationStatusID = 1 AND CAST(vwr.ExpectedCheckIn as date) = @Date AND vwr.ActualCheckIn IS NULL

	UNION ALL

	-------------Departures------------------
	SELECT CONCAT('Departures For ',Format(@Date,'dddd, MMMM d, yyyy'))
	,Format(vwr.ActualCheckIn,'dd-MMM-yyyy')
	,Format(vwr.ExpectedCheckOut,'dd-MMM-yyyy')
	,vwr.Nights
	,vwr.FolioNumber
	,vwr.FullName
	,vwr.ReservationStatus
	,rm.RoomNo
	,vwr.Adults
	,vwr.Children
	,'Departures' [TodaysAction] 
	FROM [reservation].[vwReservationDetails] vwr 
	INNER JOIN reservation.ReservedRoom rr ON vwr.ReservationID = rr.ReservationID AND rr.IsActive = 1	
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID	
	WHERE vwr.LocationID = @LocationID AND vwr.ReservationStatusID = 3 AND CAST(vwr.ExpectedCheckOut as date) = @Date AND vwr.ActualCheckOut IS NULL
	
	UNION ALL 

	--------------Stayovers-------------------
	SELECT CONCAT('Stayovers For ',Format(@Date,'dddd, MMMM d, yyyy'))
	,Format(vwr.ActualCheckIn,'dd-MMM-yyyy')
	,Format(vwr.ExpectedCheckOut,'dd-MMM-yyyy')
	,vwr.Nights
	,vwr.FolioNumber
	,vwr.FullName
	,vwr.ReservationStatus
	,rm.RoomNo
	,vwr.Adults
	,vwr.Children
	,'Stayovers' [TodaysAction] 
	FROM [reservation].[vwReservationDetails] vwr 
	INNER JOIN reservation.ReservedRoom rr ON vwr.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID	
	WHERE vwr.LocationID = @LocationID AND vwr.ReservationStatusID = 3 AND DATEDIFF(DAY,@Date,CAST(vwr.ExpectedCheckOut as date)) > 0 AND vwr.ActualCheckOut IS NULL
	
	---------------------Reports-----------------------------------
	SELECT ReservedStatus, CheckIn, CheckOut, NoOfNights, FolioNumber, GuestName, ReservationStatus, RoomNo, Adults, Children, TodaysAction 
	FROM @tab

	SELECT Format(GETDATE(),'dd-MMM-yyyy hh:mm tt') [PrintedOn]	

	--SELECT ISNULL(SUM(Adults),0) as SumOfAdInDepAndStyov, ISNULL(SUM(Children),0) as SumOfChInDepAndStyov 
	--FROM @tab WHERE TodaysAction = 'Departures' OR TodaysAction = 'Stayovers'

	--SELECT ISNULL(SUM(Adults),0) as SumOfAdInArriAndStyov, ISNULL(SUM(Children),0) as SumOfChInArriAndStyov 
	--FROM @tab WHERE TodaysAction = 'Arrivals' OR TodaysAction = 'Stayovers'
	
	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Arrivals Stayovers Departures', @UserID
END
