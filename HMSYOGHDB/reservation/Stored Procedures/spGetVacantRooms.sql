-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [reservation].[spGetVacantRooms] --39,1,20231005,20231009
(
	@RoomTypeID INT,
	@LocationID INT,
	@CheckInDateID INT,
	@CheckOutDateID INT
)
AS
BEGIN
	
		DECLARE @dtRoomTypeID as [app].[dtID];

		INSERT INTO @dtRoomTypeID
		VALUES (@RoomTypeID)
		
		SELECT r.RoomID, r.RoomNo
		FROM Products.Room r
		INNER JOIN Products.SubCategory rt ON r.SubCategoryID = rt.SubCategoryID		
		LEFT JOIN [room].[fnGetUnavailableRoom] (@CheckInDateID, @CheckOutDateID, @dtRoomTypeID, 0) AS navail ON r.RoomID = navail.RoomID
		WHERE r.LocationID = @LocationID AND r.SubCategoryID IN (SELECT ID FROM @dtRoomTypeID)	AND r.IsActive = 1 AND navail.RoomID IS NULL		
		ORDER BY r.RoomNo, rt.Name
	
END










