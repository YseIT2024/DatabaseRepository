
CREATE PROCEDURE [account].[spCreateComplimentaryTransaction]
(		
	@DrawerID INT,
	@ReservationID INT,
	@GuestID INT,
	@USDAmount DECIMAL(18,6),
	@CurrencyID INT,
	@ActualAmount DECIMAL(18,6),
	@ActualCurrencyID INT,	
	@Remarks VARCHAR(MAX) = '',	
	@UserID INT,
	@AccountingDateID INT
)
AS
BEGIN
	DECLARE @AccountTypeID int = 20; ---Complimentary
	DECLARE @TransactionTypeID int = 2; ---REC
	DECLARE @DateID int;
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @TransactionFactor int = 0;	
	DECLARE @Amount Decimal(18,6);
	DECLARE @ExchangeRate DECIMAL(18,6);	
	DECLARE @ReservedRoomRateID int;
	DECLARE @RateCurrencyID INT = NULL;
	DECLARE @RateCurrencyExchangeRate DECIMAL(18,6) = NULL;
	DECLARE @Balance DECIMAL(18,6);
	DECLARE @LocationID int;

	IF EXISTS(SELECT AccountingDateId FROM account.AccountingDates WHERE AccountingDateId = @AccountingDateID AND DrawerID = @DrawerID AND IsActive = 1)
		BEGIN
			BEGIN TRY  		
				SET @TransactionFactor = (SELECT TransactionFactor FROM account.TransactionType WHERE TransactionTypeID = @TransactionTypeID);			
				SET @ExchangeRate = (SELECT ExchangeRate FROM currency.vwCurrentExchangeRate WHERE CurrencyID = @ActualCurrencyID AND DrawerID = @DrawerID);		
				SET @DateID = CAST(FORMAT(GETDATE(),'yyyyMMdd') as INT);
				SET @Remarks = 'Complimentary' + CASE WHEN LEN(@Remarks) > 0 THEN ', ' + @Remarks ELSE '' END;
				SET @LocationID = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID)

				SET @ReservedRoomRateID = 
				(
					SELECT MAX(rat.ReservedRoomRateID)
					FROM reservation.RoomRate rat
					INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID AND rr.IsActive = 1							
					WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1
				);

				SET @RateCurrencyID =
				(
					SELECT RateCurrencyID FROM reservation.[ReservedRoom] WHERE ReservationID = @ReservationID AND IsActive = 1
				);

				SET @RateCurrencyExchangeRate =
				(
					SELECT ExchangeRate FROM currency.vwCurrentExchangeRate WHERE CurrencyID = @RateCurrencyID AND DrawerID = @DrawerID
				);
					
				SET @Amount = (@USDAmount * @RateCurrencyExchangeRate);
								
				SELECT @ActualAmount = (@ActualAmount * tt.TransactionFactor)
				,@Amount = (@Amount * tt.TransactionFactor)
				,@TransactionFactor = tt.TransactionFactor
				FROM account.TransactionType tt			
				WHERE tt.TransactionTypeID = @TransactionTypeID 			

				SELECT @Balance = Balance
				FROM account.fnGetReservationPayments(@ReservationID)

				IF(@Amount <= @Balance OR (@Amount - @Balance) <= 0.10)
					BEGIN
						INSERT INTO [guest].[GuestWallet]
						([GuestID], [TransactionTypeID], [AccountTypeID], [ReservationID], [Amount], [RateCurrencyID], [AccountingDateID], [TransactionDateTime], [Remarks], [UserID]
						,[DateID],[ReservedRoomRateID])
						VALUES(@GuestID, @TransactionTypeID, @AccountTypeID, @ReservationID, @Amount, @RateCurrencyID, @AccountingDateID ,GETDATE(), @Remarks, @UserID, 
						@DateID, @ReservedRoomRateID)	
				
						SET @Message = 'success';													
						SET @IsSuccess = 1;
						
						DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
						DECLARE @Title varchar(200) = 'Compliment Transaction: A compliment of ' + (SELECT CurrencySymbol FROM currency.Currency WHERE CurrencyID = @ActualCurrencyID)
						+ CAST(CAST(@ActualAmount as decimal(18,2)) as varchar(20)) + ' has been given to the Folio Number ' + (SELECT [reservation].[fnGetFolioNumber](@ReservationID))
						DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID:' + CAST(@UserID as varchar(10));							
						EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
					END
				ELSE
					BEGIN
						SET @Message = 'The complimentary amount cannot be greater than the balance amount.';															
						SET @IsSuccess = 0;	
					END 
			END TRY  
			BEGIN CATCH    
				SET @Message = ERROR_MESSAGE();
				SET @IsSuccess = 0; --error				
			END CATCH;
		END
	ELSE
		BEGIN
			SET @Message = 'The transaction has been failed. The accounting date is not active.';												
			SET @IsSuccess = 0;
		END

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END

