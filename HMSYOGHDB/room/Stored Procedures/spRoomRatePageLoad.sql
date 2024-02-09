
CREATE Proc [room].[spRoomRatePageLoad]
(
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT LocationID, LocationName + ' - ' + LocationCode [LocationCode]
	FROM general.[Location]
	WHERE LocationID = @LocationID

	SELECT DISTINCT rt.RoomTypeID, rt.RoomType + ' (' + rt.Description + ')' RoomType
	FROM room.RoomType rt
	INNER JOIN room.Room r ON rt.RoomTypeID = r.RoomTypeID
	WHERE r.LocationID = @LocationID AND r.IsActive = 1
	ORDER BY  rt.RoomTypeID
	
	SELECT c.CurrencyID, c.CurrencyCode
	FROM currency.Currency c	

	SELECT d.DurationID, d.Duration 
	FROM reservation.Duration d	
END




