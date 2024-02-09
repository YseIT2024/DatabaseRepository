CREATE PROCEDURE [fund].[spUpdateSealBagNumber] 
(
	@FundFlowID INT,
	@Number VARCHAR(50)
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250);
	
	BEGIN TRY  
		BEGIN TRANSACTION
			IF NOT EXISTS(SELECT * FROM fund.Flow WHERE FundFlowID = @FundFlowID AND SealbagNumber = @Number)
				BEGIN
					UPDATE fund.Flow 
					SET SealbagNumber = @Number
					WHERE FundFlowID = @FundFlowID

					SET @IsSuccess = 1; --success  			
					SET @Message = '';
				END
			ELSE
				BEGIN
					SET @IsSuccess = 0; --exists  			
					SET @Message = 'Seal bag number is already exists for another transaction!';
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
				
			SET @IsSuccess = 1; --success  			
			SET @Message = '';			
		END;  	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


