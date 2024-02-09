
CREATE PROCEDURE [service].[spDeleteService]
(
	@ServiceID int,    
	@DrawerID int,   
    @UserID int,
	@Reason varchar(200)
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;
	
	DECLARE @LocationID int = 0;
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(300) = '';
	
	SET @LocationID = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID AND IsActive = 1);
	
	IF NOT EXISTS(SELECT TransactionID FROM reservation.ServicePayment WHERE ServiceID = @ServiceID)
		BEGIN		 
			BEGIN TRY
				BEGIN TRANSACTION				
					DELETE FROM [guest].[GuestWallet] WHERE ServiceID = @ServiceID
					DELETE FROM [reservation].[ServiceDetails]WHERE ServiceID = @ServiceID
					DELETE FROM [reservation].[Service] WHERE ServiceID = @ServiceID
					
					INSERT INTO [service].[ActivityLog]
					([ServiceID],[DrawerID],[Description],[DateTime],[UserID])
					VALUES(@ServiceID, @DrawerID, 'Deleted: ' + @Reason, GETDATE(), @UserID)
									
					SET @Message = 'The invoice has been deleted successfully.';
					SET @IsSuccess = 1; --success
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

					SET @Message = 'The invoice has been deleted successfully.';
					SET @IsSuccess = 1; --success
				END;  

				---------------------------- Insert INTO activity log---------------	
				DECLARE @Act varchar(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
			END CATCH;
		END
	ELSE
		BEGIN
			SET @Message = 'The invoice cannot be updated! Payment for this invoice already been done.';														
			SET @IsSuccess = 0;
		END
		

	SELECT @IsSuccess [IsSuccess], @Message [Message];
END

