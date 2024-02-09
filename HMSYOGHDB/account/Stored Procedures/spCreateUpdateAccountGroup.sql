
CREATE PROCEDURE [account].[spCreateUpdateAccountGroup]
(	
	@AccountGroupID INT,	
	@AccountGroupe VARCHAR(250),
	@MainAccountTypeID INT,
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
				
				IF(@AccountGroupID = 0)
				BEGIN

					INSERT INTO account.AccountGroup
					(AccountGroup,MainAccountTypeID,Description)
					VALUES (@AccountGroupe ,@MainAccountTypeID, @Description)
					

					SET @AccountGroupID = SCOPE_IDENTITY();

					SET @Message = 'Account group has been added successfully.';
				END
				ELSE
				BEGIN
					
					UPDATE account.AccountGroup SET 				
					AccountGroup = @AccountGroupe,
					MainAccountTypeID = @MainAccountTypeID,
					Description = @Description					
					WHERE AccountGroupID = @AccountGroupID

					SET @Message = 'Account group has been updated successfully.';

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
			IF(@AccountGroupID = 0)
			BEGIN 
				SET @Message = 'Account group has been added successfully.';
			END
			ELSE
			BEGIN
				SET @Message = 'Account group has been updated successfully.';
			END
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @AccountGroupID as [AccountGroupID]
END










