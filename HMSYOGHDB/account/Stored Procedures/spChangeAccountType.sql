

CREATE PROCEDURE [account].[spChangeAccountType]
(
	@TransactionID int,	
	@Reason varchar(max),
	@UserID int,	
	@LocationID int,
	@DrawerID int,
	@OldAccountTypeID int,
	@NewAccountTypeID int,
	@NewTransactionTypeID int
)
AS
BEGIN
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @ReservationID INT;
	DECLARE @OldTransactionTypeID INT;
	DECLARE @Multiplier INT = 1;
	DECLARE @OldTransactionFactor INT;
	DECLARE @NewTransactionFactor INT;

	--This change is a test change to analise the Repository and version control for database

	BEGIN TRY  		
		SELECT @ReservationID = ReservationID, @OldTransactionTypeID = TransactionTypeID
		FROM account.[Transaction]
		WHERE TransactionID = @TransactionID

		SELECT @OldTransactionFactor = TransactionFactor
		FROM account.TransactionType 
		WHERE TransactionTypeID = @OldTransactionTypeID

		SELECT @NewTransactionFactor = TransactionFactor
		FROM account.TransactionType 
		WHERE TransactionTypeID = @NewTransactionTypeID

		BEGIN TRANSACTION	
			IF(@OldTransactionFactor <> @NewTransactionFactor)
			BEGIN
				SET @Multiplier = -1
			END
			
			UPDATE account.[Transaction]
			SET AccountTypeID = @NewAccountTypeID
			,TransactionTypeID = @NewTransactionTypeID
			,Amount = @Multiplier * Amount
			WHERE TransactionID = @TransactionID

			UPDATE guest.GuestWallet
			SET AccountTypeID = @NewAccountTypeID
			,TransactionTypeID = @NewTransactionTypeID
			,Amount = @Multiplier * Amount
			WHERE TransactionID = @TransactionID AND ReservationID = @ReservationID

			INSERT INTO [account].[TransactionModificationLog]
			([TransactionID],[TransactionTypeID],[NewTransactionTypeID],[AccountTypeID],[NewAccountTypeID],[LocationID],[Remarks],[DateTime],[DrawerID],[UserID])
			VALUES (@TransactionID,@OldTransactionTypeID,@NewTransactionTypeID,@OldAccountTypeID,@NewAccountTypeID,@LocationID,@Reason,GETDATE(),@DrawerID,@UserID)

			SET @Message = 'The transaction has been completed successfully.';															
			SET @IsSuccess = 1;										
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
			SET @Message = 'The transaction has been completed successfully.';
			SET @IsSuccess = 1; --success  	
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;		

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END
