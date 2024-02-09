
CREATE PROCEDURE [reservation].[spGetRoomRateType]
AS
BEGIN		
	SELECT DurationID, Duration
	FROM reservation.Duration	
	WHERE DurationID NOT IN (2,3)
END

