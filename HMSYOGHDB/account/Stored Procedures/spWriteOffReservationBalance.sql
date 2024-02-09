
CREATE PROCEDURE [account].[spWriteOffReservationBalance]
(
	@ReservationID int,
	@UserID int,
	@LocationID int,
	@DrawerID int,
	@Reason varchar(max) = ''
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250) = '';
	DECLARE @RateCurrencyID INT;
	DECLARE @Balance DECIMAL(18,6);	
	DECLARE @ReservationStatusID int;
	DECLARE @RateCurrencyExchangeRate DECIMAL(18,6);	
	DECLARE @AmountUSD DECIMAL(18,6);	
	DECLARE @AccountingDateID int = (SELECT MAX(AccountingDateId) FROM account.AccountingDates WHERE DrawerID = @DrawerID AND IsActive = 1);
	DECLARE @Desc varchar(max);
	DECLARE @TransactionID int;
	DECLARE @FolioNumber varchar(40);
	DECLARE @CurrencyCode varchar(10);
	DECLARE @GuestID int;
	DECLARE @DateID int;
	DECLARE @ReservedRoomRateID int;

	IF(@AccountingDateID > 0 AND @AccountingDateID IS NOT NULL)
		BEGIN
			SELECT 
			@ReservationStatusID = r.[ReservationStatusID]	
			,@RateCurrencyID = rr.RateCurrencyID
			,@Balance = payment.Balance
			,@FolioNumber = l.LocationCode + CAST(r.FolioNumber as varchar(20))
			,@GuestID = r.GuestID
			FROM [reservation].[Reservation] r
			INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1	
			INNER JOIN reservation.ReservationStatus rs ON r.ReservationStatusID = rs.ReservationStatusID
			INNER JOIN general.Location l ON r.LocationID = l.LocationID
			CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](r.ReservationID)) payment
			WHERE r.ReservationID = @ReservationID
	
			IF(@ReservationStatusID = 4 AND @Balance > 0)
				BEGIN
					BEGIN TRY  
						BEGIN TRANSACTION
							SET @DateID = CAST(FORMAT(GETDATE(),'yyyyMMdd') as int);	
							SET @CurrencyCode = (SELECT CurrencySymbol FROM currency.Currency WHERE CurrencyID = @RateCurrencyID)
							SET @RateCurrencyExchangeRate =	(SELECT ExchangeRate FROM currency.vwCurrentExchangeRate WHERE CurrencyID = @RateCurrencyID AND DrawerID = @DrawerID);
							SET @AmountUSD = (@Balance / @RateCurrencyExchangeRate);
							SET @Desc = @CurrencyCode + CAST(CAST(@Balance as decimal(18,2)) as varchar(10)) + ' has been written off for folio number - ' + @FolioNumber
							+ ', ' + @Reason; 

							SET @ReservedRoomRateID = 
							(
								SELECT TOP 1 rat.ReservedRoomRateID
								FROM reservation.RoomRate rat
								INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID AND rr.IsActive = 1
								INNER JOIN reservation.Reservation r ON rr.ReservationID = r.ReservationID
								WHERE r.ReservationID = @ReservationID AND rat.IsActive = 1 AND rat.DateID = @DateID
							);

							IF (@ReservedRoomRateID IS NULL)
							BEGIN
								SET @ReservedRoomRateID = 
								(
									SELECT MAX(rat.ReservedRoomRateID)
									FROM reservation.RoomRate rat
									INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID AND rr.IsActive = 1
									INNER JOIN reservation.Reservation r ON rr.ReservationID = r.ReservationID
									WHERE r.ReservationID = @ReservationID AND rat.IsActive = 1
								);
							END

							INSERT INTO [account].[Transaction]
							([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],[TransactionModeID]
							,[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID])
							VALUES(2, 91, @LocationID, @ReservationID, @AmountUSD, 1, @Balance, @RateCurrencyID, @RateCurrencyExchangeRate, @Desc, 
							1, @UserID, GETDATE(), @AccountingDateID, @DrawerID, 0)

							INSERT INTO [account].[Transaction]
							([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],[TransactionModeID]
							,[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID])
							VALUES(1, 91, @LocationID, @ReservationID, (-1)*@AmountUSD, 1, @Balance, @RateCurrencyID, @RateCurrencyExchangeRate, @Desc, 
							1, @UserID, GETDATE(), @AccountingDateID, @DrawerID, 0)

							SET @TransactionID = SCOPE_IDENTITY();			
							
							INSERT INTO [guest].[GuestWallet]
							([GuestID], [TransactionTypeID], [AccountTypeID], [ReservationID], [Amount], [RateCurrencyID], [AccountingDateID], 
							[TransactionDateTime], [Remarks], [TransactionID], [UserID], [ReservedRoomRateID], [DateID])
							VALUES(@GuestID, 2, 91, @ReservationID, @Balance, @RateCurrencyID, @AccountingDateID
							,GETDATE(), @Desc, @TransactionID, @UserID, @ReservedRoomRateID, @DateID)	
							
							INSERT INTO reservation.ReservationStatusLog
							([ReservationID], [ReservationStatusID], [Remarks], [UserID], [DateTime])
							VALUES(@ReservationID, 11 ,@Desc, @UserID, GETDATE())						
						COMMIT TRANSACTION

						SET @IsSuccess = 1; --success  			
						SET @Message = 'Write Off has been done successfully.';
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
							SET @Message = 'Write Off has been done successfully.';		
						END;  	
					END CATCH;
				END
			ELSE
				BEGIN
					SET @Message = 'Reservation has been changed from outside. Please try again.';
					SET @IsSuccess = 0; --error
				END
		END
	ELSE
		BEGIN
			SET @Message = 'The transaction has been failed. The accounting date is not active.';													
			SET @IsSuccess = 0;
		END

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END
