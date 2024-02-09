
CREATE PROCEDURE [account].[spCreateAccountTransaction]
(
	@TransactionTypeID INT,
	@AccountTypeID INT,
	@DrawerID INT,
	@ReservationID INT = NULL,
	@GuestID INT = NULL,
	@USDAmount DECIMAL(18,6),
	@CurrencyID INT,--USD
	@ActualAmount DECIMAL(18,6),
	@ActualCurrencyID INT,	
	@Remarks VARCHAR(MAX) = '',
	@TransactionModeID INT,
	@UserShiftID INT = NULL,
	@UserID INT,
	@AccountingDateID INT,
	@ContactID INT null,
	@MainAmount DECIMAL(18,6) = NULL,
	@dt_Breakups as [account].[dtCurrencyBreakup] readonly,
	@dt_Denominations as [account].[dtDenomination] readonly,
	@GuestCompanyId INT = NULL,
	@GuestCompanyTypeId INT = NULL
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @TransactionID int = 0;
	DECLARE @LocationID int = 0;
	DECLARE @TransactionFactor int = 0;	
	DECLARE @Amount Decimal(18,6);
	DECLARE @ExchangeRate DECIMAL(18,6);
	DECLARE @ReservedRoomRateID int;
	DECLARE @DateID INT;
	DECLARE @Desc varchar(max) = '';
	DECLARE @RateCurrencyID INT = NULL;
	DECLARE @RateCurrencyExchangeRate DECIMAL(18,6) = NULL;
	DECLARE @USDBalance DECIMAL(18,2) = 0;

		

	IF(@ReservationID > 0 AND @TransactionTypeID = 2 AND @AccountTypeID  = 8)
	BEGIN
		SET @USDBalance = 
		(
			SELECT distinct CAST((fn.Balance / curRate.ExchangeRate) as decimal(18,2))	
			FROM [reservation].[Reservation] r 
			INNER JOIN [reservation].[ReservedRoom] rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
			INNER JOIN [currency].[vwCurrentExchangeRate] curRate ON rr.RateCurrencyID = curRate.CurrencyID AND curRate.DrawerID = @DrawerID			
			CROSS APPLY (SELECT Balance FROM [account].[fnGetReservationPayments](r.ReservationID)) fn
			WHERE r.ReservationID = @ReservationID
		)		
	END	
	

	IF((@USDAmount - @USDBalance) > 0.90 AND @ReservationID > 0 AND @TransactionTypeID = 2 AND @AccountTypeID  = 8)
	
		BEGIN
			SET @Message = 'The transaction has been failed. You can not pay more than the balance amount.';															
			SET @IsSuccess = 0;			
		END
	ELSE
		BEGIN
			IF EXISTS(SELECT AccountingDateId FROM account.AccountingDates WHERE AccountingDateId = @AccountingDateID AND DrawerID = @DrawerID AND IsActive = 1)
			BEGIN
				BEGIN TRY  	
			
					SET @LocationID = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID AND IsActive = 1);				
					SET @ExchangeRate = (SELECT ExchangeRate FROM currency.vwCurrentExchangeRate WHERE CurrencyID =@ActualCurrencyID AND DrawerID = @DrawerID)
					SET @DateID = CAST(FORMAT(GETDATE(),'yyyyMMdd') as INT);				
					
				

					IF(@ReservationID = 0)
					BEGIN
						SET @ReservationID = NULL;					
						SET @Amount = @ActualAmount;					
					END

					IF(@ReservationID > 0)
					BEGIN
						--SET @RateCurrencyID =(SELECT RateCurrencyID FROM reservation.[ReservedRoom] WHERE ReservationID = @ReservationID AND IsActive = 1);
						SET @RateCurrencyID =1 --Set to USD Modified by Arabinda on 15*-07-2023 to set the default rate currency to USD
						SET @RateCurrencyExchangeRate =(SELECT ExchangeRate FROM currency.vwCurrentExchangeRate WHERE CurrencyID = @RateCurrencyID AND DrawerID = @DrawerID);					
						SET @Amount = (@USDAmount * @RateCurrencyExchangeRate);	
					
					END
					

					IF(@ReservationID > 0 AND (@GuestID IS NULL OR @GuestID = 0))
					BEGIN
						SELECT @GuestID = GuestID
						FROM reservation.Reservation WHERE ReservationID = @ReservationID				
					END			
					
					------------------------OK-------------------------------
					IF(@ReservationID > 0 AND @GuestID > 0)
					BEGIN
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
							)
						END					
					END
					
					------------------------OK-------------------------------
					SELECT @USDAmount = (@USDAmount * tt.TransactionFactor)
					,@ActualAmount = (@ActualAmount * tt.TransactionFactor)
					,@Amount = (@Amount * tt.TransactionFactor)
					,@TransactionFactor = tt.TransactionFactor
					FROM account.TransactionType tt			
					WHERE tt.TransactionTypeID = @TransactionTypeID 
					
					BEGIN TRANSACTION	

						IF(@TransactionModeID = 1)--Cash Transaction Mode
							BEGIN
								SET @Desc = (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks)); 					
								
								--insert into [account].[FlowTest] values(1,ERROR_MESSAGE())
	
	
								INSERT INTO [account].[Transaction]
								([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
								[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID],[GuestCompanyId],[GuestCompanyTypeId])
								VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, @USDAmount, @CurrencyID, @ActualAmount, @ActualCurrencyID, @ExchangeRate, @Desc, 
								@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID,@ContactID,@GuestCompanyId,@GuestCompanyTypeId)

								SET @TransactionID = SCOPE_IDENTITY();

								--insert into [account].[FlowTest] values(2,ERROR_MESSAGE())
			
								--IF(@GuestID > 0)
								--BEGIN
								--	INSERT INTO [guest].[GuestWallet]
								--	([GuestID], [TransactionTypeID], [AccountTypeID], [ReservationID], [Amount], [RateCurrencyID], [AccountingDateID], 
								--	[TransactionDateTime], [Remarks], [TransactionID], [UserID], [ReservedRoomRateID], [DateID])
								--	VALUES(@GuestID, @TransactionTypeID, @AccountTypeID, @ReservationID, @Amount, @RateCurrencyID, @AccountingDateID
								--	,GETDATE(), @Desc, @TransactionID, @UserID, @ReservedRoomRateID, @DateID)
								--END

								

								IF((SELECT COUNT(ID) FROM @dt_Breakups) > 0 AND @MainAmount IS NOT NULL)
								BEGIN
									IF(@TransactionFactor = 1)---CREDIT
										BEGIN
											--insert into [account].[FlowTest] values(3,ERROR_MESSAGE())
											INSERT INTO [account].[TransactionSummary]
											([TransactionID],[TransactionTypeID],[Amount],[CurrencyID])
											SELECT @TransactionID, 13, @MainAmount, @ActualCurrencyID

											--insert into [account].[FlowTest] values(4,ERROR_MESSAGE())
											INSERT INTO [account].[TransactionSummary]
											([TransactionID],[TransactionTypeID],[Amount],[CurrencyID])
											SELECT @TransactionID, 12, (-1) * dt.Amount, dt.CurrencyID
											FROM @dt_Breakups dt

											--insert into [account].[FlowTest] values(5,ERROR_MESSAGE())
										END
									ELSE IF(@TransactionFactor = -1)---DEDIT
										BEGIN
											INSERT INTO [account].[TransactionSummary]
											([TransactionID],[TransactionTypeID],[Amount],[CurrencyID])
											SELECT @TransactionID, @TransactionTypeID, (-1) * dt.Amount, dt.CurrencyID
											FROM @dt_Breakups dt
										END	
								END							

								IF((SELECT COUNT(DenominationID) FROM @dt_Denominations) > 0 AND @MainAmount IS NOT NULL)
								BEGIN
									IF(@TransactionFactor = 1)---CREDIT
										BEGIN
											INSERT INTO [account].[TransactionSummary]
											([TransactionID],[TransactionTypeID],[Amount],[CurrencyID])
											SELECT @TransactionID, 13, @MainAmount, @ActualCurrencyID

											INSERT INTO [account].[TransactionSummary]
											([TransactionID],[TransactionTypeID],[DenominationID],[Quantity],[Amount],[CurrencyID])
											SELECT @TransactionID, 12, dt.DenominationID, dt.Quantity, (-1) * dt.Total, dt.CurrencyID
											FROM @dt_Denominations dt
										END
									ELSE IF(@TransactionFactor = -1)---DEDIT
										BEGIN
											INSERT INTO [account].[TransactionSummary]
											([TransactionID],[TransactionTypeID],[DenominationID],[Quantity],[Amount],[CurrencyID])
											SELECT @TransactionID, @TransactionTypeID,dt.DenominationID, dt.Quantity, (-1) * dt.Total, dt.CurrencyID
											FROM @dt_Denominations dt
										END	
								END							

								SET @Message = 'The transaction has been completed successfully.';															
								SET @IsSuccess = 1;

								DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
								DECLARE @Title varchar(200) = (SELECT CurrencySymbol FROM currency.Currency WHERE CurrencyID = @ActualCurrencyID) + CAST(CAST(ABS(@ActualAmount) as decimal(18,2)) as varchar(20)) 
								+ ' has been ' + (SELECT TransactionType FROM account.TransactionType WHERE TransactionTypeID = @TransactionTypeID) + '. Transaction ID: ' + CAST(@TransactionID as varchar(15));
								DECLARE @NotDesc varchar(max) = @Title + ', at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID: ' + CAST(@UserID as varchar(10));							
								EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
							END	
						--ELSE IF(@TransactionModeID = 6) --Customer Wallet Transaction Mode
						--	BEGIN
						--		IF(@TransactionFactor = 1)
						--			BEGIN
						--				IF(@GuestID > 0)
						--					BEGIN
						--						IF((SELECT [guest].[fnGetGuestWalletBalanceInMainCurrency](@GuestID)) >= (SELECT ABS(@USDAmount)))
						--							BEGIN
						--								SET @Desc = (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks)); 

						--								INSERT INTO [account].[Transaction]
						--								([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
						--								[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID])
						--								VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, @USDAmount, @CurrencyID, @ActualAmount, @ActualCurrencyID, @ExchangeRate, @Desc, 
						--								@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID, @ContactID)

						--								SET @TransactionID = SCOPE_IDENTITY();	
													
						--								SET @TransactionTypeID = 1; -- Debit from guest wallet

						--								SELECT @USDAmount = (@USDAmount * tt.TransactionFactor)
						--								,@ActualAmount = (@ActualAmount * tt.TransactionFactor)
						--								,@Amount = (@Amount * tt.TransactionFactor)
						--								FROM account.TransactionType tt			
						--								WHERE tt.TransactionTypeID = @TransactionTypeID 

						--								SET @Desc = (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks)); 

						--								INSERT INTO [guest].[GuestWallet]
						--								([GuestID], [TransactionTypeID], [AccountTypeID], [ReservationID], [Amount], [RateCurrencyID], [AccountingDateID], 
						--								[TransactionDateTime], [Remarks], [TransactionID], [UserID], [ReservedRoomRateID], [DateID])
						--								VALUES(@GuestID, @TransactionTypeID, @AccountTypeID, @ReservationID, @Amount, @RateCurrencyID, @AccountingDateID
						--								,GETDATE(), @Desc, @TransactionID, @UserID, @ReservedRoomRateID, @DateID)

						--								SET @AccountTypeID = 84; --Balance REC Transaction

						--								SELECT @TransactionTypeID = TransactionTypeID
						--								FROM account.AccountType WHERE AccountTypeID = @AccountTypeID

						--								SET @Desc = (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks)); 

						--								INSERT INTO [account].[Transaction]
						--								([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
						--								[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID])
						--								VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, @USDAmount, @CurrencyID, @ActualAmount, @ActualCurrencyID, @ExchangeRate, @Desc, 
						--								@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID, @ContactID)											

						--								SET @Message = 'The transaction has been completed successfully.';															
						--								SET @IsSuccess = 1;
						--							END
						--						ELSE
						--							BEGIN
						--								SET @Message = 'The transaction has been failed. Insufficient wallet balance.';															
						--								SET @IsSuccess = 0;
						--							END
						--					END
						--				ELSE
						--					BEGIN
						--						SET @Message = 'The transaction has been failed. Guest not found.';															
						--						SET @IsSuccess = 0;
						--					END
						--			END
						--		ELSE
						--			BEGIN
						--				SET @Message = 'The transaction has been failed. Wallet balance can be used only for payment to the Hotel. Please select the transaction type as "REC".';															
						--				SET @IsSuccess = 0;
						--			END
						--	END
						--ELSE IF(@TransactionModeID = 2) --DBA Transaction Mode
						--	BEGIN
						--		SET @Desc = (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks)); 

						--		INSERT INTO [account].[Transaction]
						--		([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
						--		[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID])
						--		VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, @USDAmount, @CurrencyID, @ActualAmount, @ActualCurrencyID, @ExchangeRate, @Desc, 
						--		@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID, @ContactID)

						--		SET @TransactionID = SCOPE_IDENTITY();			
					
						--		IF(@GuestID > 0)
						--		BEGIN		
						--			INSERT INTO [guest].[GuestWallet]
						--			([GuestID], [TransactionTypeID], [AccountTypeID], [ReservationID],[Amount], [RateCurrencyID], [AccountingDateID], 
						--			[TransactionDateTime], [Remarks], [TransactionID], [UserID], [ReservedRoomRateID], [DateID])
						--			VALUES(@GuestID, @TransactionTypeID, @AccountTypeID, @ReservationID,@Amount, @RateCurrencyID, @AccountingDateID
						--			,GETDATE(), @Desc, @TransactionID, @UserID, @ReservedRoomRateID, @DateID)
						--		END

						--		IF(@TransactionFactor = 1)
						--			BEGIN
						--				SET @AccountTypeID = 84; --Balance REC Transaction
						--			END
						--		ELSE IF(@TransactionFactor = -1)
						--			BEGIN
						--				SET @AccountTypeID = 85; --Balance PAY Transaction
						--			END

						--		SELECT @TransactionTypeID = TransactionTypeID
						--		FROM account.AccountType WHERE AccountTypeID = @AccountTypeID

						--		SET @Desc = (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks)); 

						--		INSERT INTO [account].[Transaction]
						--		([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
						--		[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID])
						--		VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, (-1 * @USDAmount), @CurrencyID, (-1 * @ActualAmount), @ActualCurrencyID, @ExchangeRate, @Desc, 
						--		@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID, @ContactID)

						--		SET @Message = 'The transaction has been completed successfully.';															
						--		SET @IsSuccess = 1;
						--	END								
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
			END
		ELSE
			BEGIN
				SET @Message = 'The transaction has been failed. The accounting date is not active.';															
				SET @IsSuccess = 0;
			END
		END

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END

