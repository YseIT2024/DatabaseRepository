
CREATE Proc [room].[spGetRoomRateCodes]
(
	@ReservationID int,
	@RoomTypeID INT,
	@LocationID INT,
	@RateCurrencyID INT
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT RateID, RateCode
	FROM currency.Price p
	INNER JOIN room.Rate r ON p.PriceID = r.Adult1PriceID
	WHERE r.RoomTypeID = @RoomTypeID AND p.CurrencyID = @RateCurrencyID AND r.IsActive = 1 AND LocationID = @LocationID AND r.DurationID <> 3

	UNION

	SELECT r.RateID, RateCode 
	FROM currency.Price p
	INNER JOIN room.Rate r ON p.PriceID = r.Adult1PriceID
	INNER JOIN reservation.RoomRate rr ON r.RateID = rr.RateID
	INNER JOIN reservation.ReservedRoom rrm ON rr.ReservedRoomID = rrm.ReservedRoomID
	WHERE r.RoomTypeID = @RoomTypeID AND p.CurrencyID = @RateCurrencyID AND r.IsActive = 1 AND  rrm.ReservationID = @ReservationID AND r.DurationID = 3
END

