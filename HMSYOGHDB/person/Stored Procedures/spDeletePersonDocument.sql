-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [person].[spDeletePersonDocument] 
	-- Add the parameters for the stored procedure here
(
	@DocumentName varchar(500)
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
			
			DELETE FROM contact.Document 
			WHERE DocumentID = (SELECT DocumentID FROM general.Document WHERE DocumentUrl = @DocumentName)

			DELETE FROM general.Document
			WHERE DocumentUrl = @DocumentName
			
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
