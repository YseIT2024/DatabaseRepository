CREATE PROCEDURE [account].[spCreateLAundryPaymentAccountTransaction]
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
	@ContactID INT ,
	@MainAmount DECIMAL(18,6) = NULL,
	@dtAdvancePaymentSummary as [account].[dtAdvancePaymentBreakup] readonly,
	@OrderId int ,
	@GuestCompanyId int =0,
	@GuestCompanyTypeId int =0
 
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
	DECLARE @FolioNo int;

	-- My second change for Database Repository version control

	set @FolioNo =(select FolioNumber from reservation.[Reservation] where ReservationID=@ReservationID)
	

	--IF(@ReservationID > 0 AND @TransactionTypeID = 2 AND @AccountTypeID  = 8)
	--BEGIN
	--	SET @USDBalance = 
	--	(
	--		SELECT CAST((fn.Balance / curRate.ExchangeRate) as decimal(18,2))	
	--		FROM [reservation].[Reservation] r 
	--		INNER JOIN [reservation].[ReservedRoom] rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	--		INNER JOIN [currency].[vwCurrentExchangeRate] curRate ON rr.RateCurrencyID = curRate.CurrencyID AND curRate.DrawerID = @DrawerID			
	--		CROSS APPLY (SELECT Balance FROM [account].[fnGetReservationPayments](r.ReservationID)) fn
	--		WHERE r.ReservationID = @ReservationID
	--	)		
	--END	
	

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
					
					
					SELECT @USDAmount = (@USDAmount * tt.TransactionFactor)
					,@ActualAmount = (@ActualAmount * tt.TransactionFactor)
					,@Amount = (@Amount * tt.TransactionFactor)
					,@TransactionFactor = tt.TransactionFactor
					FROM account.TransactionType tt			
					WHERE tt.TransactionTypeID = @TransactionTypeID 
					
					BEGIN TRANSACTION	

						IF(@TransactionModeID = 1)--Cash Transaction Mode
							BEGIN
								SET @Desc =@Remarks -- (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks)); 					
								
								--insert into [account].[FlowTest] values(1,ERROR_MESSAGE())
								if @ContactID=null or @ContactID=0
								begin								
									set @ContactID=(select contactid from guest.Guest where GuestID=@GuestID)
								end
	
								INSERT INTO [account].[Transaction]
								([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
								[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID],ReferenceNo,GuestCompanyId,GuestCompanyTypeId)
								VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, @USDAmount, @CurrencyID, @ActualAmount, @ActualCurrencyID, @ExchangeRate, @Desc, 
								@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID,@ContactID,@OrderId,@GuestCompanyId,@GuestCompanyTypeId)

								SET @TransactionID = SCOPE_IDENTITY();

							 
								INSERT INTO [account].[TransactionSummary]
								([TransactionID],[TransactionTypeID],[Amount],[CurrencyID],[PaymentTypeID],Rate)
								SELECT @TransactionID, @TransactionTypeID, dt.Amount, dt.CurrencyID,dt.PaymentTypeID,dt.Rate
								FROM @dtAdvancePaymentSummary dt
								where dt.Amount>0
								
								Update [Housekeeping].[HKLaundryOrder]
								set CashPaid=@USDAmount where OrderId=@OrderId
								 
								SET @Message = 'The transaction has been completed successfully.';															
								SET @IsSuccess = 1;

								DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
								DECLARE @Title varchar(200) = (SELECT CurrencySymbol FROM currency.Currency WHERE CurrencyID = @ActualCurrencyID) + CAST(CAST(ABS(@ActualAmount) as decimal(18,2)) as varchar(20)) 
								+ ' has been ' + (SELECT TransactionType FROM account.TransactionType WHERE TransactionTypeID = @TransactionTypeID) + '. Transaction ID: ' + CAST(@TransactionID as varchar(15));
								DECLARE @NotDesc varchar(max) = @Title + ', at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID: ' + CAST(@UserID as varchar(10));							
								EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
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

