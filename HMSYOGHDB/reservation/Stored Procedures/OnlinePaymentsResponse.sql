
CREATE PROCEDURE [reservation].[OnlinePaymentsResponse]   --6845,0,'SUCCEEDED','TEST','2',10
(
	@ReferenceId int,
	@RefereenceNo varchar(max),
	@Status nvarchar(max),
	@IndentId nvarchar(max),
	@PaymentMode int,
	@Amount decimal(18,2),

	@CustomerName nvarchar(250)='',
	@MethodType nvarchar(250)='',
	@Brand nvarchar(250)='',
	@FourDigit nvarchar(250)='',
	@Payment_Gateway nvarchar(250)=''
)
AS
BEGIN
	SET XACT_ABORT ON; 
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
    --DECLARE @PaymentModeApproval int;

	--SET @PaymentMode=10 --BANK
	--SET @PaymentMode= --BANK

	DECLARE @Hold_TransactionModeID int;

	
IF @PaymentMode = 1
BEGIN
SET @Hold_TransactionModeID = 8;
END
ELSE IF @PaymentMode = 2
BEGIN
SET @Hold_TransactionModeID = 10;
END
ELSE IF @PaymentMode = 3
BEGIN
SET @Hold_TransactionModeID = 9;
END



	BEGIN TRY	
	
				 INSERT INTO [reservation].[OnlinePaymentResponse] 
				([ReferenceId]
				,[ReferenceNo]
				,[Status]
				,[IndentId]
				,[PaymentMode]
				,[CreateDateTime]
				,[Amount]
				,[CustomerName]
				,[MethodType]
				,[Brand]
				,[FourDigit],[PaymentGateway]) 
				values
				(@ReferenceId,@RefereenceNo,@status,@IndentId,Convert(nvarchar(max),
				--@PaymentMode
				@Hold_TransactionModeID
				),GETDATE(),@Amount,@CustomerName,@MethodType,@Brand,@FourDigit,@Payment_Gateway)
				 		
					
				--UPDATE [reservation].[OnlinePaymentResponse]  SET Status =@Status ,IndentId = @IndentId,
				--PaymentMode =Convert(nvarchar(max),@PaymentMode) ,ResponseTime = GETDATE(),Amount = @Amount where ReferenceNo = @RefereenceNo



					if(@status='SUCCEEDED')
					begin
			DECLARE @TransactionTypeID INT;
			DECLARE @AccountTypeID INT;
			DECLARE @DrawerID INT;
			DECLARE @ReservationID INT = NULL;
			DECLARE @GuestID INT = NULL;
			DECLARE @USDAmount DECIMAL(18,6);
			DECLARE @CurrencyID INT =1
			DECLARE @ActualAmount DECIMAL(18,6);
			DECLARE @ActualCurrencyID INT;
			DECLARE @Remarks VARCHAR(MAX) = '';
			DECLARE @TransactionModeID INT;
			DECLARE @UserShiftID INT = NULL;
			DECLARE @UserID INT=NULL;
			DECLARE @AccountingDateID INT;
			DECLARE @ContactID INT;
			DECLARE @MainAmount DECIMAL(18,6) = NULL;
			DECLARE @LocationID INT;
			--DECLARE @dtAdvancePaymentSummary as [account].[dtAdvancePaymentBreakup] readonly;
			DECLARE @ExchangeRate DECIMAL(18,6);
			DECLARE @Desc varchar(max) = '';

			declare @Cardnumber varchar(25)=' '

			if(@FourDigit is not null and LTRIM(RTRIM(@FourDigit))<>'')
			Begin
				set @Cardnumber ='XXXX '+ LTRIM(RTRIM(@FourDigit))
			End



			SET @TransactionTypeID= 2;	-- REC (Credit)	Credit To Hotel Account
			SET @AccountTypeID=23;		-- Advance Payment
			SET @DrawerID = 8; 
			SET @ReservationID = @ReferenceId;
			SET @USDAmount=@Amount;
			--SET @Remarks ='REC: $' + @Amount +', Advance Payment';
			SET @TransactionModeID = Convert(nvarchar(max),@Hold_TransactionModeID)

			

			SELECT 
			@GuestID=GuestID,
		--	@CurrencyID=CurrencyID,

			@ActualCurrencyID=CurrencyID,
			@UserID=UserID,
			@LocationID=LocationID
			FROM reservation.Reservation WHERE ReservationID=@ReferenceId


			Set @AccountingDateID =  (SELECT AccountingDateId FROM account.AccountingDates WHERE DrawerID = 1 AND IsActive = 1 );
			SET @ContactID=(SELECT TOP(1) ContactID FROM guest.Guest WHERE GuestID=(SELECT TOP(1)GuestID FROM reservation.Reservation WHERE ReservationID=@ReferenceId))
			SET @ExchangeRate = (SELECT ExchangeRate FROM currency.vwCurrentExchangeRate WHERE CurrencyID =@ActualCurrencyID AND DrawerID = 1)


			SET @Desc ='REC: $'+CAST(@Amount AS VARCHAR(50))  +', Advance Payment - ' + isnull(@MethodType,'')+' - '+ isnull(@Brand,'')+' - ' +isnull(@Cardnumber,'')
			--SET @Desc = (SELECT [account].[fnGetTransactionDescription](@TransactionTypeID,@AccountTypeID,@ActualAmount,@ActualCurrencyID,@Remarks));

			-- Advance Payment
			--exec [account].[spCreateAdvancePaymentAccountTransaction] @TransactionTypeID,@AccountTypeID,@DrawerID,@ReservationID,@GuestID,@USDAmount,@CurrencyID,@ActualAmount,@Remarks,@TransactionModeID,@UserShiftID,@UserID,@AccountingDateID,@ContactID,@MainAmount
			--UPDATE  [account].[Transaction] SET  ActualAmount=100 WHERE TransactionID IN (8502,8503)
			INSERT INTO [account].[Transaction]
			([TransactionTypeID],[AccountTypeID],[LocationID],[ReservationID],[Amount],[CurrencyID],[ActualAmount],[ActualCurrencyID],[ExchangeRate],[Remarks],
			[TransactionModeID],[UserID],[TransactionDateTime],[AccountingDateID],[DrawerID],[ContactID])
			VALUES(@TransactionTypeID, @AccountTypeID, @LocationID, @ReservationID, @USDAmount, @CurrencyID, @Amount, @ActualCurrencyID, @ExchangeRate, @Desc, 
			@TransactionModeID, @UserID, GETDATE(), @AccountingDateID, @DrawerID,@ContactID)

			declare @TranactionId int =scope_identity()
			
			insert into [account].[TransactionSummary](TransactionTypeID,TransactionID,CurrencyID,Amount,PaymentTypeID,Rate) 
			select 2,@TranactionId,1,@USDAmount,@Hold_TransactionModeID,1

			-- Confirm Booking
			if(EXISTS(select ReservationID from reservation.Reservation where ReservationID=@ReferenceId and ReservationStatusID=12))
			begin 
				exec [reservation].[ApproveReservation] @ReferenceId,@UserID
			end
								 
 
			END

				 SET @Message = 'Created successfully.';
								SET @IsSuccess = 1; --success
							
				END TRY  
				BEGIN CATCH    
					IF (XACT_STATE() = -1) 
					BEGIN  			
						SET @Message = ERROR_MESSAGE();
						SET @IsSuccess = 0; --error			
					END;    
		
				END CATCH;  

				SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
			END
