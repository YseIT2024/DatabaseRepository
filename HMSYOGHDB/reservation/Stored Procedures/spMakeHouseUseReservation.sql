
CREATE PROCEDURE [reservation].[spMakeHouseUseReservation]
(
	@ReservationID int,
	@UserID int
)
AS
BEGIN		
	DECLARE @ReservationStatusID int;
	DECLARE @OtherTran int;
	DECLARE @Message varchar(300) = '';
	DECLARE @IsSuccess bit = 0;
	DECLARE @LocationID int;
	
	SELECT @ReservationStatusID = r.ReservationStatusID, @LocationID = r.LocationID
	FROM [reservation].[Reservation] r
	WHERE r.ReservationID = @ReservationID

	SELECT @OtherTran = COUNT(gw.GuestID)
	FROM guest.GuestWallet gw
	WHERE gw.ReservationID = @ReservationID AND AccountTypeID <> 82
	
	IF(@ReservationStatusID NOT IN(1,3))
	BEGIN
		SELECT 0 IsSuccess, 'Only ''Reserved'' or ''IN-House'' reservations can be changed into House Use!' [Message];
		RETURN;
	END

	IF(@OtherTran > 0)
	BEGIN
		SELECT 0 IsSuccess, 'This reservation can''t be changed into House Use! Because some transactions have already made for this reservation.' [Message];
		RETURN;
	END

	BEGIN TRY  
		BEGIN TRANSACTION		
			UPDATE reservation.Reservation
			SET ReservationTypeID = 7
			WHERE ReservationID = @ReservationID
				
			UPDATE rat
			SET rat.DiscountID = 1,
			Rate = 0,
			RateID = 230
			FROM [reservation].[RoomRate] rat
			INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID AND rr.IsActive = 1
			WHERE rr.ReservationID = @ReservationID
				
			IF(@ReservationStatusID = 3)
			BEGIN
				UPDATE guest.GuestWallet
				SET Amount = 0
				WHERE ReservationID = @ReservationID
			END
		COMMIT TRANSACTION

		SET @IsSuccess = 1; --success	
		SET @Message = 'The reservation has been changed into ''HOUSE USE'' successfully!';
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
			SET @Message = 'The reservation has been changed into ''HOUSE USE'' successfully!';
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END
