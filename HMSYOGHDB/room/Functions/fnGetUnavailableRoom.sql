
CREATE FUNCTION [room].[fnGetUnavailableRoom]
(	
	@CheckInDateId int,
	@CheckOutDateId int,
	@dtRoomTypeID as [app].[dtID] readonly,
	@ReservationID int = 0
)
RETURNS @Output TABLE (RoomID INT) 
AS
BEGIN
	DECLARE @CheckInTime VARCHAR(10) = (SELECT [reservation].[fnGetStandardCheckInTime]());
	DECLARE @CheckOutTime VARCHAR(10) = (SELECT [reservation].[fnGetStandardCheckOutTime]());
	DECLARE @CheckInDate DATETIME = (SELECT CAST(CAST(@CheckInDateId AS VARCHAR(8)) + ' ' + @CheckInTime AS DATETIME)); 
	DECLARE @CheckOutDate DATETIME = (SELECT CAST(CAST(@CheckOutDateId AS VARCHAR(8)) + ' ' + @CheckOutTime AS DATETIME)); 

	IF(@ReservationID = 0)
		BEGIN
			INSERT INTO @Output
			SELECT r.RoomID
			FROM room.vwTodayRoomStatusHistory rsh
			INNER JOIN Products.Room r ON rsh.RoomID = r.RoomID AND r.SubCategoryID IN (SELECT ID FROM @dtRoomTypeID) 
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
			AND rsh.PrimaryStatusID IN (2,4,5)
		END
	ELSE IF(@ReservationID > 0)
		BEGIN
			INSERT INTO @Output
			SELECT r.RoomID
			FROM room.vwTodayRoomStatusHistory rsh
			INNER JOIN Products.Room r ON rsh.RoomID = r.RoomID AND r.SubCategoryID IN (SELECT ID FROM @dtRoomTypeID) 
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
			AND rsh.PrimaryStatusID IN (2,4,5) AND rsh.ReservationID NOT IN (@ReservationID)
		END

	RETURN
END







