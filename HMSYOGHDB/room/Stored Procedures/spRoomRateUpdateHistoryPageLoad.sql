
CREATE Proc [room].[spRoomRateUpdateHistoryPageLoad]
(
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT LocationID, LocationName + ' - ' + LocationCode [LocationCode]
	FROM general.[Location]
	WHERE LocationID = @LocationID

	SELECT 0 AS RoomTypeID, 'ALL' RoomType

	UNION 

	SELECT DISTINCT rt.RoomTypeID, rt.RoomType + ' (' + rt.Description + ')' RoomType
	FROM room.RoomType rt
	INNER JOIN room.Room r ON rt.RoomTypeID = r.RoomTypeID
	WHERE r.LocationID = @LocationID AND r.IsActive = 1
	ORDER BY  RoomTypeID
	
	
END




