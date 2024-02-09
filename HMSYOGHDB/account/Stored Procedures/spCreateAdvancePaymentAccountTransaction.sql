CREATE PROCEDURE [account].[spCreateAdvancePaymentAccountTransaction]
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
	@dtAdvancePaymentSummary as [account].[dtAdvancePaymentBreakup] readonly,
	@GuestCompanyId int =0,
	@GuestCompanyTypeId int =0,

	@dtAdvancePaymentReturn as [account].[dtAdvancePaymentBreakup] readonly,
    @ShortOverAmount DECIMAL(18,6) = 0,
	@ShortOverType int =0
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @TransactionID int = 0;
	DECLARE @ReturnTransactionID int = 0;
	DECLARE @ShortOverTransactionID int = 0;
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

	declare @FinanceDateId int =1--(select [app].[fnGetCurrentfinancialDateId](@DrawerID))

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

								if @ContactID=null or @ContactID=0
								begin								
									set @ContactID=(select contactid from guest.Guest where GuestID=@GuestID)
								end
	
								INSERT INTO [account].[Transaction]
								([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
								[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID],GuestComanyId,GuestCompanyTypeId,FinancialDateId)
								VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, @USDAmount, @CurrencyID, @ActualAmount, @ActualCurrencyID, @ExchangeRate, @Desc, 
								@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID,@ContactID,@GuestCompanyId,@GuestCompanyTypeId,@FinanceDateId)

								SET @TransactionID = SCOPE_IDENTITY();

							 
								INSERT INTO [account].[TransactionSummary]
								([TransactionID],[TransactionTypeID],[Amount],[CurrencyID],[PaymentTypeID],Rate)
								SELECT @TransactionID, @TransactionTypeID, dt.Amount, dt.CurrencyID,dt.PaymentTypeID,dt.Rate
								FROM @dtAdvancePaymentSummary dt
								where dt.Amount>0


								if exists(select top 1 * from @dtAdvancePaymentReturn where Amount>0)
								Begin
									declare @ReturnValinMainCurrency decimal(18,4)=[account].[fnGetMainCurrencyValue](@dtAdvancePaymentReturn)
									declare @ReturnActualCurrencyId int=1
									declare @ReturnActualCurrencyValue int=@ReturnValinMainCurrency
									declare @IsReturnIsInMultiCurrency int=(select count(*) from @dtAdvancePaymentReturn dt where dt.Amount>0)

									if(@IsReturnIsInMultiCurrency=1)
									Begin
										select @ReturnActualCurrencyId=[CurrencyID],@ReturnActualCurrencyValue=[Amount] from @dtAdvancePaymentReturn dt	where dt.Amount>0
									End


									SET @Desc = (SELECT [account].[fnGetTransactionDescription](1,85,@ReturnActualCurrencyValue,@ReturnActualCurrencyId,' Return Balance')); 

									INSERT INTO [account].[Transaction]
									([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
									[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID],GuestComanyId,GuestCompanyTypeId,FinancialDateId)
									VALUES(1, 85, @LocationID, @ReservationID, @ReturnValinMainCurrency*-1, @CurrencyID, @ReturnActualCurrencyValue*-1, @ReturnActualCurrencyId, @ExchangeRate, @Desc, 
									@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID,@ContactID,@GuestCompanyId,@GuestCompanyTypeId,@FinanceDateId)

									SET @ReturnTransactionID = SCOPE_IDENTITY();

							 
									INSERT INTO [account].[TransactionSummary]
									([TransactionID],[TransactionTypeID],[Amount],[CurrencyID],[PaymentTypeID],Rate)
									SELECT @ReturnTransactionID, 1, dt.Amount, dt.CurrencyID,dt.PaymentTypeID,dt.Rate
									FROM @dtAdvancePaymentReturn dt
									where dt.Amount>0
								End

								if(@ShortOverAmount<>0)
								Begin
									INSERT INTO [account].[Transaction]
									([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
									[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID],GuestComanyId,GuestCompanyTypeId,FinancialDateId)

									select @ShortOverType, 9, @LocationID, @ReservationID, @ShortOverAmount, 1, @ShortOverAmount, 1, 1.00
									,case when @ShortOverType=1 then 'Over '+ Convert(varchar(10),@ShortOverAmount)+' USD' else 'Short '+ Convert(varchar(10),@ShortOverAmount)+' USD' end, 
									@TransactionModeId, @UserID, GETDATE(), @AccountingDateID, @DrawerID,@ContactID,@GuestCompanyId,@GuestCompanyTypeId,@FinanceDateId

									SET @ShortOverTransactionID = SCOPE_IDENTITY();
								end



								-- Bank Cash DB Posting
							   	begin try
								 exec account.postBankCashDBTransaction @TransactionID
								 if (@ReturnTransactionID>0)
								 Begin
									 exec account.postBankCashDBTransaction  @ReturnTransactionID
								 End
								 if(@ShortOverTransactionID>0)
								 Begin
									 exec account.postBankCashDBTransaction  @ShortOverTransactionID
								 End
								End Try
							   	begin catch
							   		print 1
							   	end catch
							   	-- End Bank Cash DB Posting




								SET @Message = 'The transaction has been completed successfully.';															
								SET @IsSuccess = 1;

								DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
								DECLARE @Title varchar(200) = (SELECT CurrencySymbol FROM currency.Currency WHERE CurrencyID = @ActualCurrencyID) + CAST(CAST(ABS(@ActualAmount) as decimal(18,2)) as varchar(20)) 
								+ ' has been ' + (SELECT TransactionType FROM account.TransactionType WHERE TransactionTypeID = @TransactionTypeID) + '. Transaction ID: ' + CAST(@TransactionID as varchar(15));
								DECLARE @NotDesc varchar(max) = @Title + ', at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID: ' + CAST(@UserID as varchar(10));							
								EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	


								----------------------------Added By Somnath----------------------------
								if(@AccountTypeID=23)
								Begin 
									Declare @FolioNo int = (Select FolioNumber From reservation.Reservation Where ReservationID= @ReservationID)
									Set @NotDesc= 'Advance for ReservationID-'+ Cast(@ReservationID As Varchar(20))+', FolioNo- '+ Cast(@FolioNo As Varchar(20))+ ', Payment Breakup- '+@Desc+' ' +@NotDesc
									EXEC [app].[spInsertActivityLog] 21,@LocationID,@NotDesc,@UserID,@Message
								End
								----------------------------Added By Somnath----------------------------
							END	

		      

						 						
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
