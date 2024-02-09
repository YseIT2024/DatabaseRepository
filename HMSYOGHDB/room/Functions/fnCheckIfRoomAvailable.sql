
CREATE FUNCTION [room].[fnCheckIfRoomAvailable]
(	
	@CheckInDateId int,
	@CheckOutDateId int,
	@dtRoom as [reservation].[dtRoom] readonly
)
RETURNS @Output TABLE (RoomID INT, RSHistoryID INT, ReservationID INT) 
AS		
BEGIN
	DECLARE @CheckInTime VARCHAR(10) = (SELECT [reservation].[fnGetStandardCheckInTime]());
	DECLARE @CheckOutTime VARCHAR(10) = (SELECT [reservation].[fnGetStandardCheckOutTime]());

	DECLARE @CheckInDate DATETIME = (SELECT CAST(CAST(@CheckInDateId AS VARCHAR(8)) + ' ' + @CheckInTime AS DATETIME)); 
	DECLARE @CheckOutDate DATETIME = (SELECT CAST(CAST(@CheckOutDateId AS VARCHAR(8)) + ' ' + @CheckOutTime AS DATETIME)); 

	INSERT INTO @Output
	SELECT rsh.RoomID, rsh.RSHistoryID, rsh.ReservationID
	FROM room.RoomStatusHistory rsh
	INNER JOIN @dtRoom dt ON rsh.RoomID = dt.RoomID
	WHERE 
	(
		((SELECT CAST(CAST(rsh.FromDateID AS VARCHAR(8))+' '+@CheckInTime AS DATETIME)) BETWEEN @CheckInDate AND @CheckOutDate)		
		OR
		((SELECT CAST(CAST(rsh.ToDateID AS VARCHAR(8))+' '+@CheckOutTime AS DATETIME)) BETWEEN @CheckInDate AND @CheckOutDate)		
		OR
		(@CheckInDate BETWEEN (SELECT CAST(CAST(rsh.FromDateID AS VARCHAR(8))+' '+@CheckInTime AS DATETIME)) AND (SELECT CAST(CAST(rsh.ToDateID AS VARCHAR(8))+' '+@CheckOutTime AS DATETIME)))
		OR
		(@CheckOutDate BETWEEN (SELECT CAST(CAST(rsh.FromDateID AS VARCHAR(8))+' '+@CheckInTime AS DATETIME)) AND (SELECT CAST(CAST(rsh.ToDateID AS VARCHAR(8))+' '+@CheckOutTime AS DATETIME)))		
	)
	AND rsh.RoomStatusID IN (2,4,5)

	RETURN
END









