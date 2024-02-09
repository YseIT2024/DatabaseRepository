
CREATE PROCEDURE [currency].[spUpdateExchangeRate] --713,2,8.55,1,1
(
	@ID INT,
	@CurrencyID INT,
	@NewRate Decimal(18,6),	
	@DrawerID INT,
	@UserID INT
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess int = 0;
	DECLARE @Message varchar(250) = '';		
	DECLARE @DenomTotal Decimal(18,6);
	DECLARE @OldDenomTotalInUSD Decimal(18,6);
	DECLARE @NewDenomTotalInUSD Decimal(18,6);
	DECLARE @Diff Decimal(18,6) = 0;	
	DECLARE @IsDiff int = 0;		
	DECLARE @LocationID int;
	DECLARE @Balance Decimal(18,2) = 0;
	DECLARE @AccountingDate Date;
	DECLARE @AccountingDateID INT;
	DECLARE @OldRate DECIMAL(18,6);
	DECLARE @IsStrongerThanUSD bit;
	DECLARE @AccountTypeID int;
	
	SELECT @AccountingDateID = AccountingDateId, @AccountingDate = AccountingDate 
	FROM account.AccountingDates 
	WHERE IsActive = 1 AND DrawerID = @DrawerID
				 
	SET @LocationID = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);
	SET @Balance = 	(SELECT account.fnGetCashFigureBalance(@DrawerID));		
	
	IF(@AccountingDateID IS NULL OR @AccountingDateID = 0)
		BEGIN		        
			SET @Message = 'The accounting date is closed! Please open the accounting date and try again.';
			SET @IsSuccess = 0;		
		END	
	ELSE IF(@Balance <> 0)
		BEGIN
			SET @Message = 'Drawer is not balanced! Please balance the Drawer and try again.';													
			SET @IsSuccess = 0;								
		END
	ELSE
		BEGIN TRY 
			BEGIN TRANSACTION			
				SELECT @IsStrongerThanUSD  = IsStrongerThanMainCurrency
				FROM currency.Currency 
				WHERE CurrencyID = @CurrencyID
		
				SET @OldRate = (SELECT NewRate FROM [currency].[ExchangeRateHistory] WHERE ID = @ID AND IsActive = 1);

				SELECT @DenomTotal = SUM(DenomTotalValue)
				FROM [currency].[DenominationStatistics] 
				WHERE AccountingDateId = @AccountingDateID AND DrawerID = @DrawerID
				AND DenominationID IN 
				(
					SELECT DISTINCT DenominationID 
					FROM [currency].[Denomination] d
					INNER JOIN [currency].[DenominationType] dt ON d.DenominationTypeID = dt.DenominationTypeID
					WHERE dt.CurrencyID = @CurrencyID AND d.IsActive = 1 AND dt.IsActive = 1 AND dt.DenominationValueTypeID IN (1,2)
				)									

				IF(@IsStrongerThanUSD = 1)
				BEGIN
					SET @NewRate = (1/@NewRate);
				END

				UPDATE [currency].[ExchangeRateHistory] 
				SET IsActive = 0 
				WHERE ID = @ID

				INSERT INTO [currency].[ExchangeRateHistory]
				([LocationID], [CurrencyID], [ExchangeRateToCurrencyID], [OldRate], [NewRate], [AccountingDate], [RateChangeTime], [IsActive], [DrawerID], [UserID], [IsStrongerThanMainCurrency])
				VALUES(@LocationID, @CurrencyID, 1, @OldRate, @NewRate, @AccountingDate, GETDATE(), 1, @DrawerID, @UserID, @IsStrongerThanUSD)
				
				UPDATE currency.DailyRateChangeHistory 
				SET IsActive = 0 
				WHERE AccountingDateId = @AccountingDateID AND CurrencyID = @CurrencyID

				INSERT INTO currency.DailyRateChangeHistory
				([DrawerID], [AccountingDateId], [CurrencyID], [ExchangeRateToCurrencyID], [Rate], [IsStrongerThanMainCurrency])
				VALUES(@DrawerID, @AccountingDateId, @CurrencyID, 1, @NewRate, @IsStrongerThanUSD)			

				SET @OldDenomTotalInUSD = (@DenomTotal / @OldRate);	
				SET @NewDenomTotalInUSD = (@DenomTotal / @NewRate);
				SET @Diff = (@NewDenomTotalInUSD - @OldDenomTotalInUSD);
				
				IF(@Diff <> 0)
				BEGIN
					SET @IsDiff = 1;
				END									
				
				IF(@Diff > 0)
					BEGIN
						SET @AccountTypeID = 26; --Rate Change Profit

						INSERT INTO [account].[Transaction]
						(TransactionTypeID, AccountTypeID, LocationID, ContactID, Amount, CurrencyID, ActualAmount, ActualCurrencyID, ExchangeRate,	Remarks, TransactionModeID, AccountingDateID, TransactionDateTime, DrawerID, UserID)
						VALUES(2, @AccountTypeID, @LocationID, 0, @Diff, 1, @Diff, 1, @NewRate, 'Rate Change Profit!', 1, @AccountingDateID, GETDATE(), @DrawerID, @UserID)						
					END	
				ELSE IF(@Diff < 0)
					BEGIN
						SET @AccountTypeID = 27; --Rate Change Loss

						INSERT INTO [account].[Transaction]
						(TransactionTypeID, AccountTypeID, LocationID, ContactID, Amount, CurrencyID, ActualAmount, ActualCurrencyID, ExchangeRate,	Remarks, TransactionModeID, AccountingDateID, TransactionDateTime, DrawerID, UserID)
						VALUES(1, @AccountTypeID, @LocationID, 0, @Diff, 1, @Diff, 1, @NewRate, 'Rate Change Loss!', 1, @AccountingDateID, GETDATE(), @DrawerID, @UserID)
					END		 	

				DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
				DECLARE @Title varchar(200) = 'Exchange Rate: ' + (SELECT CurrencyCode FROM currency.Currency WHERE CurrencyID = @CurrencyID) + ' rate has updated to ' + CAST(@NewRate as varchar(10)) 
			    DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID:' + CAST(@UserID as varchar(10));
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc			
			COMMIT TRANSACTION	

			SET @Message = 'Exchange rate has been updated successfully.';													
			SET @IsSuccess = 1;	
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
			
				BEGIN  
					SET @IsSuccess = 1; --success  			
					SET @Message = 'Exchange rate has been updated successfully.';
				END
			END;  

			---------------------------- Insert into activity log---------------	
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
			EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
		END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message', @IsDiff 'RateChange';
END


