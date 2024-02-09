
CREATE PROCEDURE [app].[spSaveUserManual]
(
	@Extnsn varchar(10),
	@UserID int,
	@LocationID int	
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250) = '';
	DECLARE @DocName varchar(25);
	
	BEGIN TRY  
		BEGIN TRANSACTION
			UPDATE [app].[Document]
			SET IsActive = 0
			WHERE IsActive = 1

			SET @DocName = (SELECT FORMAT(GETDATE(),'ddMMyyhhmmssff')) + @Extnsn

			INSERT INTO [app].[Document]
			([DocName],[IsActive],[DateTime],[UserID],[LocationID])
			VALUES(@DocName,1,GETDATE(),@UserID,@LocationID)								
		COMMIT TRANSACTION

		SET @IsSuccess = 1; --success  			
		SET @Message = @DocName;
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
			SET @Message = @DocName;
		END;  	
	END CATCH;				

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END
