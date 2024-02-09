
CREATE Proc [reservation].[spExtendReservationPageLoad] --1182,1
(
	@ReservationID INT,
	@LocationID INT	
)
AS
BEGIN		
	DECLARE @RateID int;
	DECLARE @RateCode VARCHAR(100);
	DECLARE @RateCurrencyID int;
	DECLARE @RoomTypeID int;
	DECLARE @DateID int = (SELECT CONVERT(INT,FORMAT(GETDATE(),'yyyyMMdd')));

	SELECT @RateID = MAX(RateID)
	,@RateCurrencyID = RateCurrencyID
	,@RoomTypeID = RoomTypeID
	FROM reservation.[Reservation] r
	INNER JOIN reservation.[ReservedRoom] rr ON r.ReservationID = rr.ReservationID 
	INNER JOIN reservation.[RoomRate] rt ON rr.ReservedRoomID = rt.ReservedRoomID 
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID
	WHERE r.ReservationID = @ReservationID AND r.LocationID = @LocationID AND rr.IsActive = 1 AND rt.IsActive = 1 AND rt.IsVoid = 0
	GROUP BY RateCurrencyID, RoomTypeID

	SET @RateCode = (SELECT RateCode FROM room.Rate WHERE RateID = @RateID);

	SELECT FolioNumber
	,FullName as [Name]		
	,FORMAT(ISNULL(ActualCheckIn,ExpectedCheckIn),'dd-MMM-yyyy') [CheckIn] 
	,FORMAT(ExpectedCheckOut,'dd-MMM-yyyy') [CheckOut]
	,Discount
	,RateCurrencyID
	,@RateID RateID
	,@RateCode RateCode
	FROM [reservation].[vwReservationDetails] 
	WHERE ReservationID = @ReservationID AND LocationID = @LocationID

	SELECT r.RateID, r.RateCode 
	FROM  room.Rate r 
	INNER JOIN currency.Price p1 ON  r.Adult1PriceID = p1.PriceID 
	INNER JOIN currency.Price p2 ON  r.Adult2PriceID = p2.PriceID 
	WHERE r.RoomTypeID = @RoomTypeID AND LocationID = @LocationID AND p1.CurrencyID = @RateCurrencyID AND r.IsActive = 1 AND IsSpecialRate = 0

	UNION

	SELECT r.RateID, r.RateCode 
	FROM  room.Rate r 
	INNER JOIN currency.Price p1 ON  r.Adult1PriceID = p1.PriceID 
	INNER JOIN currency.Price p2 ON  r.Adult2PriceID = p2.PriceID
	WHERE r.RoomTypeID = @RoomTypeID AND LocationID = @LocationID AND p1.CurrencyID = @RateCurrencyID AND r.IsActive = 1 AND IsSpecialRate = 1
	AND @DateID BETWEEN r.FromDateID AND r.ToDateID

	UNION

	SELECT RateID, RateCode
	FROM room.Rate
	WHERE RateID = @RateID
END


