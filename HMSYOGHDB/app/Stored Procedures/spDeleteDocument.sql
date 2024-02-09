
CREATE PROCEDURE [app].[spDeleteDocument]
(
	@NewDocumentName varchar(100),
	@OldDocumentName varchar(100)	
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250) = '';
	
	BEGIN TRY  
		BEGIN TRANSACTION			
			UPDATE [app].[Document]
			SET [IsActive] = 1      
			WHERE [DocName] = @OldDocumentName 

			UPDATE [app].[Document]
			SET [IsActive] = 0   
			WHERE [DocName] = @NewDocumentName
		COMMIT TRANSACTION		

		SET @IsSuccess = 1; --success  			
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
		END;  	
	END CATCH;				

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END
