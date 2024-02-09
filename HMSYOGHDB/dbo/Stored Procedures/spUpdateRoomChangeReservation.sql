-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateRoomChangeReservation]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  
	DECLARE @ReservationIDs TABLE(ID INT IDENTITY(1,1), ReservedRoomID INT, ReservationID INT)
	DECLARE @RSHistory TABLE(ID INT, RSHistoryID INT, RoomID INT, FromDateID INT, FromDate DATETIME, ToDateID INT)
	DECLARE @Count INT;
	DECLARE @Init INT;
	DECLARE @ReservationID INT;
	DECLARE @ReservedRoomID INT;
	DECLARE @Count1 INT 
	DECLARE @Init1 INT
	DECLARE @RSHistoryID INT
	DECLARE @FromDateID INT
	DECLARE @ToDateID INT
	DECLARE @FromDate DATETIME
	DECLARE @RoomID INT
	DECLARE @ResRoomID INT;

	INSERT INTO @ReservationIDs
	SELECT ReservedRoomID, r.ReservationID 
	FROM reservation.ReservedRoom rr
	INNER JOIN reservation.Reservation r ON rr.ReservationID = r.ReservationID
	WHERE ShiftedRoomID IS NOT NULL AND IsActive = 1 and ReservationStatusID = 4 
	ORDER BY ReservationID

	SET @Init = 1;
	SET @Count = (SELECT Count(ID) FROM @ReservationIDs);	

	select * from @ReservationIDs

	WHILE (@Count >= @Init)
	BEGIN
		SELECT @ReservationID = ReservationID, @ReservedRoomID = ReservedRoomID 
		FROM @ReservationIDs WHERE ID = @Init
		
		DELETE FROM @RSHistory

		INSERT INTO @RSHistory
		SELECT ROW_NUMBER() OVER(ORDER BY RSHistoryID),  RSHistoryID, RoomID, FromDateID, FromDate, ToDateID 
		FROM room.RoomStatusHistory rsh	
		WHERE ReservationID = @ReservationID AND RSHistoryID NOT IN (SELECT RSHistoryID FROM [todo].[ToDo])
		ORDER BY RSHistoryID, rsh.ReservationID

		SET @Count1 = (SELECT COUNT(ID) FROM @RSHistory)
		SET @Init1 = 2;

		--select * from @RSHistory

		WHILE @Count1 >= @Init1
		BEGIN
			SET @RSHistoryID = (SELECT RSHistoryID FROM @RSHistory WHERE ID = @Init1 -1)

			SELECT @RoomID = RoomID, @FromDateID = FromDateID, @FromDate = FromDate, @ToDateID = ToDateID 
			FROM  @RSHistory WHERE ID = @Init1 

			UPDATE room.RoomStatusHistory
			SET ToDateID = @FromDateID,
			ToDate = @FromDate
			WHERE RSHistoryID = @RSHistoryID

			UPDATE [reservation].[ReservedRoom]
			SET IsActive = 0
			WHERE ReservedRoomID = @ReservedRoomID

			INSERT INTO [reservation].[ReservedRoom]
			([ReservationID],[RoomID],[StandardCheckInOutTimeID],[RateCurrencyID],[ShiftedRoomID],[IsActive],[UserID],[ModifiedDate])
			SELECT ReservationID,@RoomID,1,RateCurrencyID,NULL,1,1,GETDATE()
			FROM [reservation].[ReservedRoom]
			WHERE ReservedRoomID = @ReservedRoomID 

			SET @ResRoomID = SCOPE_IDENTITY()

			UPDATE reservation.RoomRate
			SET ReservedRoomID = @ResRoomID
			WHERE ReservedRoomID = @ReservedRoomID AND DateID BETWEEN @FromDateID AND @ToDateID

			SET @ReservedRoomID = @ResRoomID

			SET @Init1 = @Init1 + 1;
		END

		SET @Init = @Init + 1;
	END 
END
