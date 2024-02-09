CREATE PROC [contact].[EmergencyContactIU] 
    @EmrContactID int = null,
	@ReservationID int, 
    @EmrContactName varchar(100),
    @EmrContactNumber varchar(15),
    @EmrContactRelation varchar(150),
    @UserID int,
	@LocationID int,
    @IsActive bit = 1
AS 
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';

    --BEGIN TRY	
	BEGIN TRAN
		IF(@EmrContactID < 1)
		BEGIN
					INSERT INTO [contact].[EmergencyContact] (EmrContactName, ReservationID, EmrContactNumber, EmrContactRelation,
																   CreatedBy, CreatedDate, IsActive)
					Values( @EmrContactName,@ReservationID, @EmrContactNumber, @EmrContactRelation, @UserID, 
						   GetDate(), @IsActive)						  

					SET @IsSuccess = 1; --success 
					SET @Message = 'Energency contact added successfully.';	
					SET @Title = 'Energency contact for Reservation: ' + STR(@ReservationID) + ' added';
					

		END
		ELSE
		BEGIN
					UPDATE [contact].[EmergencyContact]
					SET    EmrContactName = @EmrContactName, EmrContactNumber = @EmrContactNumber, EmrContactRelation = @EmrContactRelation,
						   CreatedBy = @UserID, CreatedDate = GetDate(), IsActive = @IsActive
					WHERE  EmrContactID = @EmrContactID and ReservationID = @ReservationID

					SET @IsSuccess = 1; --success 
					SET @Message = 'Energency contact have been updated successfully.';	
					SET @Title = 'Energency contact for Reservation: ' + STR(@ReservationID) + ' updated';

		END

	
		SET @NotDesc = @Message + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc


-- This SP is called in '[reservation].[CheckInTrans]' SP, So dont return any values/messages
    
 
 
 --   END TRY  
	--BEGIN CATCH    
	--	IF (XACT_STATE() = -1) 
	--	BEGIN  			
	--		ROLLBACK TRANSACTION; 			
	--		SET @Message = ERROR_MESSAGE();			
	--		SET @IsSuccess = 0; --error			
	--	END; 		
		
	--	---------------------------- Insert into activity log---------------	
	--	DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
	--	EXEC [app].[spInsertActivityLog]28,@LocationID,@Act,@UserID	
	--END CATCH;  

	--SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];

	COMMIT
END
