
CREATE PROCEDURE [account].[CloseCurrentAccountingDate] --1,1
(
	@DrawerID INT,
	@UserID INT,
	@IgnorePendingCheckout bit = 0 
)
AS
BEGIN
	DECLARE @Status int = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @CurrentDateTime DATETIME = GETDATE();
	DECLARE @ActiveAccountingDate DATE;
	DECLARE @ActiveAccountingDateId INT;
	DECLARE @CurrentDayNumber INT = 0;
	DECLARE @ActiveMinClosingTime TIME(7);
	DECLARE @ActiveMaxClosingTime TIME(7);
	DECLARE @CurrentTime TIME(7) = GETDATE();
	DECLARE @CloseDateTime DATETIME;
	DECLARE @LocationID INT;
	DECLARE @BalanceTotal DECIMAL(18,2) = 0.00;	
	DECLARE @HotelCashFigureHasToBeZero bit;
	DECLARE @CasinoCashFigureHasToBeZero bit;
	DECLARE @HotelCash DECIMAL(18,3);
	DECLARE @CasinoCash DECIMAL(18,3);
	DECLARE @temp table(FolioNumber varchar(20), GuestName varchar(250), ActualCheckIn varchar(15), ExpectedCheckOut varchar(15));

	BEGIN TRY	
		SET @LocationID = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

		IF NOT Exists(SELECT AccountingDateId FROM account.AccountingDates WHERE DrawerID = @DrawerID AND IsActive = 1)
			BEGIN				
				SET @Status = -2; --already closed
				SET @Message = 'The accounting date is already closed! Please login again.';

				SELECT @Status AS [Status], @Message AS [Message]
				RETURN			
			END

		SELECT @CurrentDayNumber = DATEPART( WEEKDAY, @CurrentDateTime)

		SELECT @ActiveAccountingDateId = AccountingDateId, @ActiveAccountingDate = AccountingDate
		FROM  account.AccountingDates 
		WHERE (DrawerID = @DrawerID) AND (IsActive = 1)

		SELECT @ActiveMinClosingTime = MinClosingTime, @ActiveMaxClosingTime = MaxClosingTime 
		FROM app.Drawer
		WHERE (DrawerID = @DrawerID) 

		SET @CloseDateTime = CONVERT(DATETIME, Convert(VARCHAR, @ActiveAccountingDate) +' '+ CONVERT(VARCHAR(5), @ActiveMinClosingTime))		
		
		IF(GETDATE() < @CloseDateTime)
			BEGIN					
				SET @Status = 0; --warning
				SET @Message = 'The accounting date cannot be closed before '+ CONVERT(VARCHAR(19), @CloseDateTime, 120) + ' CLOSING TIME!';

				SELECT @Status AS [Status], @Message AS [Message]
				RETURN
			END	
			
		SELECT @CasinoCashFigureHasToBeZero = CasinoCashFigureHasToBeZero, @HotelCashFigureHasToBeZero = 		HotelCashFigureHasToBeZero
		FROM general.[Location]		
		WHERE LocationID = @LocationID

		SELECT 
		@HotelCash = SUM(CASE WHEN dt.DenominationValueTypeID = 1 THEN ds.DenomTotalValue / vwc.ExchangeRate ELSE 0 END)
		,@CasinoCash = SUM(CASE WHEN dt.DenominationValueTypeID = 2 THEN ds.DenomTotalValue / vwc.ExchangeRate ELSE 0 END)
		FROM [currency].[DenominationStatistics] ds 
		INNER JOIN currency.Denomination d ON ds.DenominationID = d.DenominationID
		INNER JOIN currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID
		INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID 
		INNER JOIN [currency].[vwCurrentExchangeRate] vwc ON c.CurrencyID = vwc.CurrencyID  AND vwc.DrawerID = @DrawerID	
		WHERE ds.DrawerID = @DrawerID AND AccountingDateId = @ActiveAccountingDateId

		IF(@HotelCashFigureHasToBeZero = 1 AND @HotelCash > 0)
		BEGIN
			SET @Status = 0; --warning
			SET @Message = 'The accounting date cannot be closed! All Hotel Cash denomination quantity must be zero!';

			SELECT @Status AS [Status], @Message AS [Message]
			RETURN
		END

		IF(@CasinoCashFigureHasToBeZero = 1 AND @CasinoCash > 0)
		BEGIN
			SET @Status = 0; --warning
			SET @Message = 'The accounting date cannot be closed! All Casino Cash denomination quantity must be zero!';

			SELECT @Status AS [Status], @Message AS [Message]
			RETURN
		END

		SET  @BalanceTotal = (SELECT [account].[fnGetCashFigureBalance](@DrawerID))

		DECLARE @UpperLimit DECIMAL(18,2) = 0.10;
		DECLARE @LowerLimit DECIMAL(18,2) = -0.10;

		IF((@BalanceTotal > @UpperLimit) OR (@BalanceTotal < @LowerLimit))
			BEGIN				
				SET @Status = 0; --not balanced
				SET @Message = 'The Drawer is not balanced! Please balance the Drawer first then close the accounting date.';
					
				SELECT @Status AS [Status], @Message AS [Message]
				RETURN
			END
				
		IF(@IgnorePendingCheckout = 0)
		BEGIN			
			INSERT INTO @temp	
			SELECT (l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
			,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]
			,FORMAT(r.[ActualCheckIn], 'dd-MMM-yyyy') [ActualCheckIn]
			,FORMAT(r.[ExpectedCheckOut], 'dd-MMM-yyyy') [ExpectedCheckOut]
			FROM [reservation].[Reservation] r
			INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
			INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
			INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
			INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
			WHERE r.ActualCheckOut IS NULL AND r.ReservationStatusID = 3 AND r.LocationID = @LocationID AND CAST(r.ExpectedCheckOut as date) <= @ActiveAccountingDate

			IF EXISTS(SELECT FolioNumber FROM @temp)
			BEGIN
				SET @Status = -1; --Checkout pending
				SET @Message = 'There are pending check out!';
					
				SELECT @Status AS [Status], @Message AS [Message]
				SELECT * FROM @temp

				RETURN
			END
		END

		UPDATE account.AccountingDates 
		SET  IsActive = 0
		WHERE DrawerID = @DrawerID AND (AccountingDateId = @ActiveAccountingDateId)			

		SET @Status = 1; --success
		SET @Message = 'The accounting date has been closed successfully!';		

		DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
		DECLARE @Title varchar(200) = 'Closed accounting date ' + FORMAT(@ActiveAccountingDate,'dd-MMM-yyyy') +' for ' +@Drawer;
		DECLARE @Desc varchar(max) = 'Closed accounting date ' + FORMAT(@ActiveAccountingDate,'dd-MMM-yyyy') +' for ' +@Drawer
		+ ' on '+ FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + ' by User ID '+ CAST(@UserID as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @Desc
	END TRY
	BEGIN CATCH		
		SET @Message = ERROR_MESSAGE();
		SET @Status = 0; --error	 
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @Status AS [Status], @Message AS [Message]
END

