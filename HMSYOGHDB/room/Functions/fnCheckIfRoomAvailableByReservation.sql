
CREATE FUNCTION [room].[fnCheckIfRoomAvailableByReservation]
(	
	@CheckInDateId int,
	@CheckOutDateId int,
	@ReservationID int
)
RETURNS @Output TABLE (ReservationID INT)
AS		
BEGIN
	DECLARE @CheckInTime VARCHAR(10) = (SELECT [reservation].[fnGetStandardCheckInTime]());
	DECLARE @CheckOutTime VARCHAR(10) = (SELECT [reservation].[fnGetStandardCheckOutTime]());
	DECLARE @CheckInDate DATETIME = (SELECT CAST(CAST(@CheckInDateId AS VARCHAR(8)) + ' ' + @CheckInTime AS DATETIME));
	DECLARE @CheckOutDate DATETIME = (SELECT CAST(CAST(@CheckOutDateId AS VARCHAR(8)) + ' ' + @CheckOutTime AS DATETIME));

	INSERT INTO @Output
	SELECT rsh.ReservationID
	FROM room.RoomStatusHistory rsh
	INNER JOIN
	(
		SELECT RoomID 
		FROM reservation.ReservedRoom 
		WHERE ReservationID = @ReservationID AND IsActive = 1
	) room_id ON rsh.RoomID = room_id.RoomID
	WHERE 
	rsh.ReservationID <> @ReservationID AND rsh.RoomStatusID IN (2,4,5) 
	AND 
	(
		((SELECT CAST(CAST(rsh.FromDateID AS VARCHAR(8)) + ' ' + @CheckInTime AS DATETIME)) BETWEEN @CheckInDate AND @CheckOutDate)		
		OR
		((SELECT CAST(CAST(rsh.ToDateID AS VARCHAR(8)) + ' ' + @CheckOutTime AS DATETIME)) BETWEEN @CheckInDate AND @CheckOutDate)		
		OR
		(@CheckInDate BETWEEN (SELECT CAST(CAST(rsh.FromDateID AS VARCHAR(8)) + ' ' + @CheckInTime AS DATETIME)) AND (SELECT CAST(CAST(rsh.ToDateID AS VARCHAR(8)) + ' ' + @CheckOutTime AS DATETIME)))
		OR
		(@CheckOutDate BETWEEN (SELECT CAST(CAST(rsh.FromDateID AS VARCHAR(8)) + ' ' + @CheckInTime AS DATETIME)) AND (SELECT CAST(CAST(rsh.ToDateID AS VARCHAR(8)) + ' ' + @CheckOutTime AS DATETIME)))		
	)

	RETURN
END





