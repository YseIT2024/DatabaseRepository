
CREATE PROCEDURE [room].[spGetRoomStatusByLocation]--1
(
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT r.RoomID
	,1 RoomStatusID
	,r.RoomNo	
	,rt.RoomType	
	,f.[Floor]	
	,'Available' RoomStatus	
	FROM room.Room r
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID
	INNER JOIN room.[Floor] f ON r.FloorID = f.FloorID
	--INNER JOIN room.RoomStatus rs ON r.RoomStatusID = rs.RoomStatusID	
	WHERE r.LocationID = @LocationID
END









