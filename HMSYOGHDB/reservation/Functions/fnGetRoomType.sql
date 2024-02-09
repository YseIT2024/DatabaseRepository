create FUNCTION [reservation].[fnGetRoomType] 
(	
	@ReservationId int	
)
RETURNS varchar(255)
AS	
BEGIN
	DECLARE @strRoomType VARCHAR(255);

		SELECT @strRoomType = COALESCE(@strRoomType + ', ', '') + PR.Remarks
		FROM Products.Room PR
		WHERE PR.RoomID IN (
			SELECT DISTINCT RoomID
			FROM [reservation].[ReservedRoom]
			WHERE ReservationID = @ReservationId
)

RETURN @strRoomType
END



