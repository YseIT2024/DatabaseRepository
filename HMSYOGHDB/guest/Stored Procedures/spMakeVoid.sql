
CREATE PROCEDURE [guest].[spMakeVoid]
(	
	@ReservationID int,
	@WalletID int,
	@UserID int,
	@Comment varchar(max),
	@DrawerID int
)
AS
BEGIN
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @ReservedRoomRateID int;
	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID)

	BEGIN TRY
		BEGIN TRANSACTION
			SELECT @ReservedRoomRateID = ReservedRoomRateID 
			FROM guest.GuestWallet 
			WHERE WalletID = @WalletID

			UPDATE guest.GuestWallet
			SET IsVoid = 1
			WHERE WalletID = @WalletID

			UPDATE reservation.RoomRate
			SET IsVoid = 1
			WHERE ReservedRoomRateID = @ReservedRoomRateID

			SET @Comment =@Comment + ' Make void ReservationID -> '+ CAST(@ReservationID as varchar(10)) + ' WalletID-> ' + CAST(@WalletID as varchar(10))
			+ ' UserID-> ' + CAST(@UserID as varchar(10)) + ' ReservedRoomRateID -> ' + CAST(@ReservedRoomRateID as varchar(12));

			EXEC [app].[spInsertIntoAudit] @Comment

			SET @IsSuccess = 1;--success  
			SET @Message = 'The void has been made successfully.';

			DECLARE @BookingDate varchar(11) =(SELECT FORMAT(d.Date, 'yyyy-MMM-dd') FROM reservation.RoomRate r 
			INNER JOIN general.Date d ON r.DateID = d.DateID
			WHERE r.ReservedRoomRateID = @ReservedRoomRateID)

			DECLARE @Folio varchar(50) = ((SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
			+ (SELECT CAST(FolioNumber as varchar) FROM reservation.Reservation WHERE ReservationID = @ReservationID))

			DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);

			DECLARE @Title varchar(200) = 'Make Void: ' + '''' + @BookingDate + '''' +' date has voided for reservation folio number ' + @Folio
			DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID:' + CAST(@UserID as varchar(10));
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
			SET @Message = 'The void has been made successfully.';
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END





