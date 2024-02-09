
CREATE PROCEDURE [account].[OpenNewAccountingDate] --1,1
(
	@DrawerID INT,
	@UserID INT 
)
AS
BEGIN
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @OldAccDateId INT;
	DECLARE @NewAccDateId INT;
	DECLARE @AccDate DATE;
	DECLARE @MaxDefaultTime TIME(7) = '23:59:00';
	DECLARE @MinDefaultTime TIME(7) = '23:59:00';
	DECLARE @LocationID INT = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

	BEGIN TRY
		SELECT @OldAccDateId =  MAX(AccountingDateId) 
		FROM account.AccountingDates 
		WHERE (IsActive = 0) AND (DrawerID = @DrawerID)		

		IF Exists(SELECT DrawerID  FROM  app.Drawer WHERE (DrawerID = @DrawerID) AND (IsActive = 0))
		BEGIN
			SET @IsSuccess = 0; --drawer deactivated
			SET @Message = 'This Drawer is deactivated. Please contact the system administrator for further assistance.';

			SELECT @IsSuccess AS [IsSuccess], @Message AS [Message] 	
						
			RETURN
		END

		SELECT  @AccDate = AccountingDate 
		FROM account.accountingDates 
		WHERE AccountingDateId= @OldAccDateId

		IF(@AccDate IS NULL)
		BEGIN
			SET @AccDate  = GETDATE();
		END

		IF Exists(SELECT AccountingDateId FROM account.AccountingDates WHERE (DrawerID = @DrawerID) AND (IsActive = 1))
		BEGIN
			SET @IsSuccess = 0; --already exists
			SET @Message = 'The Drawer is already open! Please login again.';	
				
			SELECT @IsSuccess AS [IsSuccess], @Message AS [Message] 	
					
			RETURN
		END										

		BEGIN TRANSACTION
			INSERT INTO account.AccountingDates(AccountingDate, IsActive, DrawerID)
			VALUES(DATEADD(DAY,1,@AccDate), 1, @DrawerID)

			SET @NewAccDateId =  SCOPE_IDENTITY();

			INSERT INTO currency.DenominationStatistics
			(DenominationId, DenomQuantity, DrawerID, AccountingDateId, DenomTotalValue, DenominationTotalMainCurrencyValue)
			SELECT d.DenominationId, ISNULL(ds.DenomQuantity,0), @DrawerID, @NewAccDateId, ISNULL(ds.DenomTotalValue,0), ISNULL(ds.DenominationTotalMainCurrencyValue,0)
			FROM [currency].[Denomination] d  
			LEFT JOIN [currency].[DenominationStatistics] ds ON d.DenominationId = ds.DenominationID
			WHERE ds.AccountingDateId = @OldAccDateId AND ds.DrawerID = @DrawerID	

			INSERT INTO currency.DailyRateChangeHistory
			([DrawerID], [AccountingDateId], [CurrencyID], [ExchangeRateToCurrencyID], [Rate], [IsStrongerThanMainCurrency], [IsActive])
			SELECT @DrawerID, @NewAccDateId, c.CurrencyID, 1, vwR.ExchangeRate, c.IsStrongerThanMainCurrency, 1
			FROM [currency].[vwCurrentExchangeRate] vwR
			INNER JOIN currency.Currency c ON vwR.CurrencyID = C.CurrencyID and vwR.DrawerID = @DrawerID
			WHERE DrawerID = @DrawerID

			DECLARE @NewAccountingDate date = (SELECT AccountingDate FROM account.AccountingDates WHERE AccountingDateId = @NewAccDateId)
			DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
			DECLARE @Title varchar(200) = 'Open new accounting date ' + FORMAT(@NewAccountingDate,'dd-MMM-yyyy') +' for ' +@Drawer;
			DECLARE @Desc varchar(max) = 'Open new accounting date ' + FORMAT(@NewAccountingDate,'dd-MMM-yyyy') +' for ' +@Drawer + ' on '+ FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + ' by User ID '+ CAST(@UserID as varchar(10));
			EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @Desc
		COMMIT TRANSACTION

		SET @IsSuccess = 1; --success
		SET @Message = 'The accounting date has been opened successfully.';
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
			SET @Message = 'The accounting date has been opened successfully.';
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

