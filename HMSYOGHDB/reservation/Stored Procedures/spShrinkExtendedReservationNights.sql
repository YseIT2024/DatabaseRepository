CREATE Proc [reservation].[spShrinkExtendedReservationNights]
(
	@Days int,
	@ReservationID int,
	@LocationID int,
	@UserID int
)
AS
BEGIN	
	SET XACT_ABORT ON;
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @ReservedRoomID int;
	DECLARE @ReservedRoomRateID int;
	DECLARE @CheckOutDate date;
	DECLARE @CheckOutDateId int;
	DECLARE @Nights int;
	DECLARE @ReservationStatusID int;
	DECLARE @RoomID int;

	SELECT @CheckOutDate = ISNULL(ActualCheckOut,ExpectedCheckOut), @Nights = Nights, @ReservationStatusID = ReservationStatusID
	FROM [reservation].[Reservation]
	WHERE ReservationID = @ReservationID AND LocationID = @LocationID

	SET @CheckOutDate = DATEADD(Day,-@Days, @CheckOutDate);
	SET @CheckOutDateId = (SELECT CAST(FORMAT(@CheckOutDate,'yyyyMMdd') as int));

	IF (@Days >= @Nights)
		BEGIN
			SET @IsSuccess = 0;
			SET @Message = 'Shrink nights can not be greater or equal to the actual nights.';		
		END
	ELSE		
		BEGIN TRY
			BEGIN TRANSACTION
				SELECT @ReservedRoomID = rr.ReservedRoomID, @RoomID = rr.RoomID
				FROM reservation.ReservedRoom rr
				WHERE rr.ReservationID = @ReservationID AND IsActive = 1

				IF(@ReservationStatusID = 1 or @ReservationStatusID = 3) ---- 1.Reserved, 2.IN-House
					BEGIN
						UPDATE [reservation].[Reservation]
						SET	[ExpectedCheckOut] = @CheckOutDate
						,[Nights] = [Nights] - @Days				
						WHERE ReservationID = @ReservationID
					END
				ELSE IF(@ReservationStatusID = 4) ----Checked Out
					BEGIN
						UPDATE [reservation].[Reservation]
						SET	[ActualCheckOut] = @CheckOutDate
						,[Nights] = [Nights] - @Days				
						WHERE ReservationID = @ReservationID
					END

				INSERT INTO [reservation].[ReservationStatusLog]
				([ReservationID],[ReservationStatusID],[Remarks],[UserID],[DateTime])
				VALUES(@ReservationID, 8, 'Shrank reservation by ' + CAST(@Days as varchar(4)) + ' nights.', @UserID, GETDATE())

				UPDATE [room].[RoomStatusHistory]
				SET [ToDateID] = @CheckOutDateId
				,[ToDate] = @CheckOutDate
				,[UserID] = @UserID
				WHERE [ReservationID] = @ReservationID AND RoomID = @RoomID AND IsPrimaryStatus = 1

				WHILE(@Days > 0)
				BEGIN
					SET @ReservedRoomRateID  = (SELECT MAX(ReservedRoomRateID) FROM reservation.RoomRate WHERE ReservedRoomID = @ReservedRoomID)

					DELETE FROM [reservation].[RoomRate]
					WHERE ReservedRoomRateID = @ReservedRoomRateID

					DELETE FROM [guest].[GuestWallet]
					WHERE ReservedRoomRateID = @ReservedRoomRateID		
					
					SET @Days -= 1;
				END	

				SET @IsSuccess = 1; --success
				SET @Message = 'The reservation has been shrunk successfully.';

				DECLARE @Folio varchar(50);
				DECLARE @Guest varchar(200);

				SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
				FROM reservation.Reservation r
				INNER JOIN general.Location l ON r.LocationID = l.LocationID
				INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
				INNER JOIN contact.Details d ON g.ContactID = d.ContactID
				WHERE r.ReservationID = @ReservationID

				DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
				DECLARE @Title varchar(200) = 'Shrink Reservation: ' + @Guest + '(' + @Folio + ')' + ' reservation has shrunk by '
				+ CAST(@Days as varchar(4)) + ' night(s)'
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
				SET @Message = 'The reservation has been shrunk successfully.';
			END;
		
			---------------------------- Insert into activity log---------------
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());
			EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID
		END CATCH;

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

