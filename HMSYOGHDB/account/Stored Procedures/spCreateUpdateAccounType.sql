
CREATE PROCEDURE [account].[spCreateUpdateAccounType]
(	
	@AccountTypeID INT,
	@AccountNumber INT,
	@AccountType VARCHAR(60),
	@Description VARCHAR(50),
	@AccountGroupID INT,
	@TransactionTypeID INT = NULL,
	@ShowInUI BIT,
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
	DECLARE @Title varchar(200);	
	
	IF NOT EXISTS(SELECT AccountNumber FROM account.AccountType WHERE AccountNumber = @AccountNumber AND AccountTypeID <> @AccountTypeID)
		BEGIN
			BEGIN TRY
				BEGIN TRANSACTION				
					IF(@AccountTypeID = 0)
						BEGIN
							INSERT INTO account.AccountType
							(AccountNumber,AccountType,Description,AccountGroupID,TransactionTypeID,ShowInUI,DisplayOrder)
							VALUES (@AccountNumber,@AccountType,@Description,@AccountGroupID,@TransactionTypeID,@ShowInUI,1)

							SET @AccountTypeID = SCOPE_IDENTITY();

							SET @Message = 'New account type has been added successfully.';

							SET @Title = 'Account Type: ' + (SELECT AccountType FROM account.AccountType WHERE AccountTypeID = @AccountTypeID) + ' has added ' 
							
						END
					ELSE
						BEGIN					
							UPDATE account.AccountType SET 
							AccountNumber = @AccountNumber,
							AccountType = @AccountType,
							Description = @Description,
							AccountGroupID = @AccountGroupID,
							TransactionTypeID = @TransactionTypeID,
							ShowInUI =@ShowInUI
							WHERE AccountTypeID = @AccountTypeID

							SET @Message = 'Account type has been updated successfully.';

							SET @Title = 'Account Type: ' + (SELECT AccountType FROM account.AccountType WHERE AccountTypeID = @AccountTypeID) + ' has updated ' 
						
						END						

					SET @IsSuccess = 1; --success
					
					DECLARE @NotDesc varchar(max) = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
				
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
				 
					IF(@AccountTypeID = 0)
						BEGIN 
							SET @Message = 'New account type has been added successfully.';
						END
					ELSE
						BEGIN
							SET @Message = 'Account type has been updated successfully.';
						END
				END;  
		
				---------------------------- Insert into activity log---------------	
				DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
			END CATCH;  
		END
	ELSE
		BEGIN
			SET @Message = 'Account number already exists in database. Please enter unique account number.';
			SET @IsSuccess = 0; 	
		END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @AccountTypeID as [AccountTypeID]
END







