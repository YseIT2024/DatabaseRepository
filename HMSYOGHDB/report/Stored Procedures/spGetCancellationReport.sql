
CREATE PROCEDURE [report].[spGetCancellationReport]
(
	@LocationID int,
	@FromDate datetime,
	@ToDate datetime,
	@UserID int = null
) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @LocationName VARCHAR(50) = (SELECT LocationName from [general].[Location] where LocationID = @LocationID);
	DECLARE @LocationCode VARCHAR(20) = (SELECT LocationCode from [general].[Location] where LocationID = @LocationID);
	DECLARE @PrintedOn varchar(20) = Format(GETDATE(),'dd-MMM-yyyy hh:mm tt');	

	SELECT Distinct(vwr.FolioNumber) FolioNumber
	,CONCAT(vwr.FirstName, ' ', vwr.LastName) [Name]
	,CONCAT(vwr.City, ' - ', vwr.State) City_State
	,vwr.Rooms
	,rrt.RoomType
	,FORMAT(vwr.ExpectedCheckIn,'dd-MMM-yyyy') CheckIn
	,vwr.Nights
	,FORMAT(vwr.ExpectedCheckOut,'dd-MMM-yyyy') CheckOut
	,'' RateCode
	,CASE WHEN keydr.ReservationID IS NULL THEN 0.00 ELSE keydr.KeyDepositInEuro END Deposit
	,at.TransactionMode HoldInformation
	,Format(rrl.DateTime,'dd-MMM-yyyy') CancellationDate
	,rrl.Remarks [Reason]	
	FROM [reservation].[ReservationStatusLog] rrl
	INNER JOIN [reservation].[vwReservationDetails] vwr ON rrl.ReservationID = vwr.ReservationID AND rrl.ReservationStatusID = 2
	INNER JOIN [account].[TransactionMode] at ON vwr.Hold = at.TransactionMode
	INNER JOIN [reservation].[ReservedRoom] rrr ON vwr.ReservationID = rrr.ReservationID AND rrr.IsActive = 1
	INNER JOIN [room].[Room] rrm ON rrr.RoomID = rrm.RoomID
	INNER JOIN [room].[RoomType] rrt ON rrm.RoomTypeID = rrt.RoomTypeID	
	LEFT JOIN [reservation].[vwReservationKeyDepositAndKeyRefund] keydr ON vwr.ReservationID = keydr.ReservationID
	WHERE vwr.LocationID = @LocationID AND CAST(rrl.DateTime AS DATE) BETWEEN @FromDate AND @ToDate

	SELECT @PrintedOn PrintedOn

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Cancellation Report', @UserID
END


