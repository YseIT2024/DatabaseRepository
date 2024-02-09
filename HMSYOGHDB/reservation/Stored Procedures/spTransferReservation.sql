
CREATE Proc [reservation].[spTransferReservation] 
(
	@NewRoomID INT,	
	@OldRoomID INT,
	@ReservationID INT,
	@CheckInDate DATE,
	@CheckOutDate DATE,	
	@TotalAmount DECIMAL(18,3),
	@LocationID INT,
	@UserID INT,	
	@dtRate as reservation.dtRoomRate READONLY
)
AS
BEGIN
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @dtRoom as [reservation].[dtRoom];
	DECLARE @ReservedRoomID int;
	DECLARE @ReservedRoomRateID int;
	DECLARE @CheckInDateId int = (SELECT CAST(FORMAT(@CheckInDate,'yyyyMMdd') as int));
	DECLARE @CheckOutDateId int = (SELECT CAST(FORMAT(@CheckOutDate,'yyyyMMdd') as int));	
	DECLARE @OldRoom int;
	DECLARE @NewRoom int;	
	DECLARE @RateCurrencyID int;
	DECLARE @ReservationStatusID int;
	DECLARE @ReservationTypeID int;
	
	SELECT @ReservationStatusID = ReservationStatusID, @ReservationTypeID = ReservationTypeID 
	FROM reservation.Reservation 
	WHERE ReservationID = @ReservationID

	INSERT INTO @dtRoom (RoomID)
	VALUES(@NewRoomID);
	DECLARE @temp table (DateID int, DiscountID int);

	IF (@ReservationStatusID <> 1) --Status Reserved
		BEGIN
			SET @IsSuccess = 0; 
			SET @Message = 'Reservation status has been changed from outside! Please refresh the page and try again!';
		END
	ELSE IF EXISTS(SELECT tRooms.RoomID FROM (SELECT * FROM [room].[fnCheckIfRoomAvailable](@CheckInDateId, @CheckOutDateId, @dtRoom)) AS tRooms WHERE tRooms.RoomID = @NewRoomID AND tRooms.ReservationID <> @ReservationID)
		BEGIN
		   SET @IsSuccess = 0;
		   SET @Message = 'Selected room is not available! Please refresh the page and try again!';
		END
	ELSE IF(@OldRoomID != (SELECT [RoomID] FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID))
		BEGIN
			SET @IsSuccess = 0; 

			DECLARE @RoomNo varchar(10) = 
			(
				SELECT CAST((SELECT r.RoomNo FROM [reservation].[ReservedRoom] rr 
				INNER JOIN room.Room r ON rr.RoomID = r.RoomID
				WHERE ReservationID = @ReservationID) as varchar(10))
			);

			SET @Message = 'The reservation has already been shifted to Room no <b>' + @RoomNo + '</b>! Please refresh the page.';
		END
	ELSE IF((select count(RateID) from @dtRate) = 0)
		BEGIN
			SET @IsSuccess = 0;
		   SET @Message = 'Please select valid room rate!';
		END
	ELSE 			
		BEGIN TRY
			BEGIN TRANSACTION			
				SELECT @OldRoom = RoomNo , @RateCurrencyID = RateCurrencyID, @ReservedRoomID = ReservedRoomID
				FROM [reservation].[ReservedRoom] rm 
				INNER JOIN [room].[Room] r ON rm.RoomID = r.RoomID 
				WHERE rm.ReservationID = @ReservationID

				SET @NewRoom = (SELECT RoomNo FROM [room].[Room] WHERE RoomID = @NewRoomID)

				INSERT INTO @temp
				SELECT DateID,DiscountID
				FROM reservation.RoomRate
				WHERE ReservedRoomID = @ReservedRoomID

				DELETE FROM [reservation].[RoomRate] WHERE ReservedRoomID = @ReservedRoomID
				DELETE FROM [reservation].[ReservedRoom] WHERE ReservedRoomID = @ReservedRoomID
				DELETE FROM [room].[RoomStatusHistory] 	WHERE [ReservationID] = @ReservationID AND RoomID = @OldRoomID AND IsPrimaryStatus = 1
				
				INSERT INTO [reservation].[ReservationStatusLog]
				([ReservationID],[ReservationStatusID],[Remarks],[UserID],[DateTime])
				VALUES(@ReservationID, 7, 'Moved reservation id- ' + CONVERT(VARCHAR, @ReservationID) +', From Room No- ' 
				+ CONVERT(VARCHAR, @OldRoom) + ' to Room No- ' + CONVERT(VARCHAR, @NewRoom) +'.', @UserID, GETDATE())

				INSERT INTO [room].[RoomStatusHistory]
				([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[ReservationID],[UserID])	
				VALUES(@NewRoomID, @CheckInDateId, @CheckOutDateId, 2, 1, @CheckInDate, @CheckOutDate, @ReservationID, @UserID)			

				INSERT INTO [reservation].[ReservedRoom]
				([ReservationID],[RoomID],[StandardCheckInOutTimeID],[IsActive],[RateCurrencyID])
				VALUES(@ReservationID, @NewRoomID, 1, 1, @RateCurrencyID)				
				
				SET @ReservedRoomID = SCOPE_IDENTITY();

				INSERT INTO [reservation].[ReservedRoomLog]
				([ReservationID],[RoomID],[Date],[UserID])
				VALUES(@ReservationID, @NewRoomID, GETDATE(), @UserID)

				IF(@ReservationTypeID = 7)	--HOUSE USE			
					BEGIN
						INSERT INTO [reservation].[RoomRate]
						([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
						SELECT @ReservedRoomID, r.DateID, 230, 0, 1
						FROM @dtRate r		
						INNER JOIN @temp t ON r.DateID = t.DateID 
					END
				ELSE
					BEGIN
						INSERT INTO [reservation].[RoomRate]
						([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
						SELECT @ReservedRoomID, r.DateID, r.RateID, r.Amount, t.DiscountID
						FROM @dtRate r		
						INNER JOIN @temp t ON r.DateID = t.DateID 
					END						

				SET @IsSuccess = 1; --success
				SET @Message = 'The reservation has been moved successfully.';

				DECLARE @Folio varchar(50); 
				DECLARE @Guest varchar(200);

				SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
				FROM reservation.Reservation r
				INNER JOIN general.Location l ON r.LocationID = l.LocationID
				INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
				INNER JOIN contact.Details d ON g.ContactID = d.ContactID
				WHERE r.ReservationID = @ReservationID

				DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
				DECLARE @Title varchar(200) = 'Move Reservation: ' + @Guest + '(' + @Folio + ')' + ' reservation has moved from '
				+ CAST(@OldRoom as varchar) + ' to ' + CAST(@NewRoom as varchar) + ' Room No'
				DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
			COMMIT TRANSACTION
		END TRY  
		BEGIN CATCH    
			IF (XACT_STATE() = -1) 
			BEGIN  			
				ROLLBACK TRANSACTION;  

				SET @Message = ERROR_MESSAGE();
				SET @IsSuccess = 0; --error
				SET @ReservationID = -1; --error
			END;    
    
			IF (XACT_STATE() = 1)  
			BEGIN  			
				COMMIT TRANSACTION;   

				SET @IsSuccess = 1; --success  
				SET @Message = 'The reservation has been moved successfully.';
			END;  
		
			---------------------------- Insert into activity log---------------	
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
			EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
		END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]	
END

