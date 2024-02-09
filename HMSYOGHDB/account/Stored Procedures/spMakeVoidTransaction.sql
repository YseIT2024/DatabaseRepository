CREATE PROCEDURE [account].[spMakeVoidTransaction]
(
	@DrawerID int,
	@UserID int,
	@TransactionID int,
	@Reason varchar(max)
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250);
	DECLARE @LocationID INT = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);
	DECLARE @ActualCurrencyID INT;
	DECLARE @ActualAmount DECIMAL(18,2);	
	DECLARE @ReservationID INT; 
	
	SELECT @ReservationID =  ISNULL(ReservationID,0),
    @ActualCurrencyID = ActualCurrencyID, 
	@ActualAmount = ActualAmount FROM account.[Transaction]
	WHERE TransactionId = @TransactionID
	
	BEGIN TRY  
		BEGIN TRANSACTION
			INSERT INTO [account].[VoidTransaction]
			([TransactionID],[TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[ContactID],[Amount],[CurrencyID],
			[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],[TransactionModeID],[AccountingDateID],[TransactionDateTime]
			,[DrawerID],[UserShiftID],[UserID],[VoidBy],[Reason],[DateTime]) 
			SELECT [TransactionID],[TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[ContactID],[Amount],[CurrencyID],
			[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],[TransactionModeID],[AccountingDateID],[TransactionDateTime]
			,[DrawerID],[UserShiftID],[UserID],@UserID, @Reason, GETDATE()
			FROM [account].[Transaction] WHERE TransactionID = @TransactionID

			IF(@ReservationID > 0)
				BEGIN
					DELETE FROM [guest].[GuestWallet]
					WHERE TransactionID = @TransactionID
				END

				DELETE FROM [account].[Transaction] 
				WHERE TransactionID = @TransactionID

			SET @IsSuccess = 1; --success  			
			SET @Message = 'Transaction has been deleted successfully.';

			DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
			DECLARE @Title varchar(200) = 'Void Transaction: ' + 'Transaction ID ' + CAST(@TransactionID as varchar) + ' has deleted '
			+ (SELECT CurrencySymbol FROM currency.Currency WHERE CurrencyID = @ActualCurrencyID)+ CAST(CAST(@ActualAmount as decimal(18,2)) as varchar(20));
			DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID:' + CAST(@UserID as varchar(10));
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
			SET @Message = 'Transaction has been deleted successfully.';			
		END;  	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


