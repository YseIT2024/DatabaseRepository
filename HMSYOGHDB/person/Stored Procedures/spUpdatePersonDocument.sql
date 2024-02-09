-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [person].[spUpdatePersonDocument] 
	-- Add the parameters for the stored procedure here
(
	@DocumentID INT
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
			
			UPDATE general.Document
			SET IsActive = 0
			WHERE DocumentID = @DocumentID
			
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
			
			SET @IsSuccess = 1; --success  		
			
		END;  	
	END CATCH;				

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END
