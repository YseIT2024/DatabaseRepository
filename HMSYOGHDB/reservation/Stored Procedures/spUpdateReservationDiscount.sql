
CREATE PROCEDURE [reservation].[spUpdateReservationDiscount]
(
	@ReservationID int,
	@OldDiscount decimal(18,2),
	@NewDiscount decimal(18,2),
	@UserID int,
	@LocationID int
)
AS
BEGIN
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @DiscountID int;
	DECLARE @Folio varchar(50); 
	DECLARE @Guest varchar(200);

	IF EXISTS ((SELECT ReservationID FROM [reservation].[Reservation] WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID IN (1,3) AND CompanyID = 0)
			UNION ALL (SELECT ReservationID FROM [reservation].[Reservation] WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID IN (1,3,4) AND CompanyID > 0))
		BEGIN		  		
			BEGIN TRY
				BEGIN TRANSACTION			
					SELECT @DiscountID = d.[DiscountID]
					FROM reservation.Discount d
					WHERE d.[Percentage] = @NewDiscount

					IF(@DiscountID IS NULL)
					BEGIN
						INSERT INTO [reservation].[Discount]
						([Percentage], [Description])
						VALUES(@NewDiscount, CAST(@NewDiscount as varchar(5)) + '% DISCOUNT')

						SET @DiscountID = SCOPE_IDENTITY();
					END

					UPDATE rat
					SET rat.DiscountID = @DiscountID
					FROM [reservation].[RoomRate] rat
					INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID
					WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rr.IsActive = 1

					SET @IsSuccess = 1; --success
					SET @Message = 'Discount has been updated successfully!';

					SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
					FROM reservation.Reservation r
					INNER JOIN general.Location l ON r.LocationID = l.LocationID
					INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
					INNER JOIN contact.Details d ON g.ContactID = d.ContactID
					WHERE r.ReservationID = @ReservationID

					DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
					DECLARE @Title varchar(200) = 'Discount Updated: ' + @Guest + '(' + @Folio + ')' + ' discount has been updated from ' + CAST(@OldDiscount as varchar) + ' to ' + CAST(@NewDiscount as varchar);
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
				END;    
    
				IF (XACT_STATE() = 1)  
				BEGIN  			
					COMMIT TRANSACTION;   

					SET @IsSuccess = 1; --success  
					SET @Message = 'Discount has been updated successfully!';
				END;  
		
				---------------------------- Insert into activity log---------------	
				DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
			END CATCH;  
		END
	ELSE
		BEGIN
			SET @Message = 'Discount cannot be updated! The reservation status has been changed from outside.';
			SET @IsSuccess = 0;
		END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]	
END
