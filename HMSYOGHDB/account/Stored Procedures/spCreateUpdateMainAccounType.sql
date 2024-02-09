
CREATE PROCEDURE [account].[spCreateUpdateMainAccounType]
(	
	@MainAccountTypeID INT,	
	@MainAccountType VARCHAR(50),
	@Description VARCHAR(50),	
	@LocationID INT,
	@UserID INT

)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	
	BEGIN TRY		
	
			BEGIN TRANSACTION
				
				IF(@MainAccountTypeID = 0)
				BEGIN

					INSERT INTO account.MainAccountType
					(MainAccountType,Description)
					VALUES (@MainAccountType ,@Description)
					

					SET @MainAccountTypeID = SCOPE_IDENTITY();

					SET @Message = 'Main account type has been added successfully.';
				END
				ELSE
				BEGIN
					
					UPDATE account.MainAccountType SET					
					MainAccountType = @MainAccountType,
					Description = @Description					
					WHERE MainAccountTypeID = @MainAccountTypeID

					SET @Message = 'Main account type has been updated successfully.';

				END						

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
			IF(@MainAccountTypeID = 0)
			BEGIN 
				SET @Message = 'Main account type has been added successfully.';
			END
			ELSE
			BEGIN
				SET @Message = 'Main account type has been updated successfully.';
			END
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @MainAccountTypeID as [MainAccountTypeID]
END










