CREATE Proc [room].[spAddRateType]
(
	@RateType VARCHAR(15),
	@LocationID INT,
	@UserID INT
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	
	BEGIN TRY  
		BEGIN TRANSACTION
			IF NOT EXISTS(SELECT DurationID FROM reservation.Duration WHERE Duration = @RateType)
			BEGIN
				INSERT INTO [reservation].[Duration]
							([Duration]
							,[DisplayText])
					  VALUES
							(@RateType
							,'Night')

				SET @IsSuccess = 1;
				SET @Message = 'Rate Type has been added successfully'
			END
			ELSE
			BEGIN
				SET @Message = 'Rate Type is already exists, please enter valid rate type!'
			END

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
		
		END;  

		-------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



