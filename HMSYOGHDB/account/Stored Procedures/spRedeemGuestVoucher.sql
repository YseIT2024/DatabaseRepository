
CREATE PROCEDURE [account].[spRedeemGuestVoucher]
(	
	@DrawerID int,
	@ReservationID int,
	@GuestID int,
	@Remarks VARCHAR(MAX) = NULL,
	@UserID int,
	@AccountingDateID int,
	@VoucherID int
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable
	-- when the constraint violation occurs.
	SET XACT_ABORT ON;
	
	DECLARE @TransactionTypeID int = 2;  ---REC
	DECLARE @AccountTypeID int = 24;  ---Guest Voucher
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @LocationID int = 0;
	DECLARE @ReservedRoomRateID int;
	DECLARE @DateID int;
	DECLARE @VoucherNumber varchar(30);
	DECLARE @VoucherCurrencyID int;
	DECLARE @ReservationCurrencyID int;
	DECLARE @ReservationCurrency varchar(5);	
	DECLARE @Balance decimal(18,6);
	DECLARE @VoucherAmount decimal(18,6);
	DECLARE @NewVoucherAmount decimal(18,6);
	DECLARE @Rate_VoucherCurrency decimal(18,6);
	DECLARE @Rate_ReservationCurrency decimal(18,6);
	DECLARE @ValidFrom datetime;
	DECLARE @ValidTo datetime;
	DECLARE @tbl_voucher TABLE([VoucherID] int,[VoucherNumber] varchar(50));
	DECLARE @VoucherReservationID int;
	
	IF EXISTS(SELECT AccountingDateId FROM account.AccountingDates WHERE AccountingDateId = @AccountingDateID AND DrawerID = @DrawerID AND IsActive = 1)
		BEGIN
			IF EXISTS(SELECT VoucherID FROM guest.Voucher WHERE VoucherID = @VoucherID AND RedeemOn IS NULL AND GETDATE() BETWEEN ValidFrom AND ValidTo)
				BEGIN
					BEGIN TRY
						SET @LocationID = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID AND IsActive = 1);
						SET @DateID = CAST(FORMAT(GETDATE(),'yyyyMMdd') as int);
						
						IF(@Remarks IS NULL)
						BEGIN
							SET @Remarks = '';
						END	
				
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

						BEGIN TRANSACTION	
							SELECT @Balance = Balance 
							FROM [account].[fnGetReservationPayments](@ReservationID)

							IF(@Balance > 0)
								BEGIN
									SELECT @VoucherNumber = VoucherNumber
									,@VoucherAmount = Amount
									,@VoucherCurrencyID = CurrencyID
									,@ValidFrom = ValidFrom
									,@ValidTo = ValidTo			
									,@VoucherReservationID = ReservationID
									FROM guest.Voucher
									WHERE VoucherID = @VoucherID

									SELECT @ReservationCurrencyID = rr.RateCurrencyID
									FROM reservation.Reservation r
									INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
									WHERE r.ReservationID = @ReservationID

									SELECT @ReservationCurrency = [CurrencySymbol]
									FROM currency.Currency
									WHERE CurrencyID = @ReservationCurrencyID

									SET @Rate_VoucherCurrency = (
										SELECT ExchangeRate
										FROM currency.vwCurrentExchangeRate
										WHERE DrawerID = @DrawerID AND CurrencyID = @VoucherCurrencyID
									);

									SET @Rate_ReservationCurrency = (
										SELECT ExchangeRate
										FROM currency.vwCurrentExchangeRate
										WHERE DrawerID = @DrawerID AND CurrencyID = @ReservationCurrencyID
									);

									IF(@VoucherCurrencyID <> @ReservationCurrencyID)
									BEGIN
										----SRD/EUR to USD----
										SET @VoucherAmount = (@VoucherAmount / @Rate_VoucherCurrency);
										----USD to Rate Currency----
										SET @VoucherAmount = (@VoucherAmount * @Rate_ReservationCurrency);
									END
								
									IF(@VoucherAmount > @Balance)
									BEGIN
										SET @NewVoucherAmount = (@VoucherAmount - @Balance);
										SET @VoucherAmount = @Balance;									
									END
							
									SET @Remarks = 'Redeem guest voucher - ' + @VoucherNumber + ' ' + @Remarks;

									INSERT INTO [guest].[GuestWallet]
									([GuestID], [TransactionTypeID], [AccountTypeID], [ReservationID], [Amount], [RateCurrencyID], [AccountingDateID], [TransactionDateTime], [Remarks]
									,[UserID], [ReservedRoomRateID], [DateID])
									VALUES(@GuestID, @TransactionTypeID, @AccountTypeID, @ReservationID, @VoucherAmount, @ReservationCurrencyID, @AccountingDateID
									,GETDATE(), @Remarks, @UserID, @ReservedRoomRateID, @DateID)

									UPDATE guest.Voucher
									SET [RedeemReservationID] = @ReservationID
									,RedeemLocationID = @LocationID
									,RedeemGuestID = @GuestID
									,RedeemUserID = @UserID
									,RedeemOn = GETDATE()
									,Description = 'Redeem Amount - ' + @ReservationCurrency + CAST(@VoucherAmount AS VARCHAR(10))
									WHERE VoucherID = @VoucherID

									IF(@NewVoucherAmount > 0.1)
										BEGIN
											----SRD/EUR to USD----
											SET @NewVoucherAmount = (@NewVoucherAmount / @Rate_ReservationCurrency);
											----USD to Rate Currency----
											SET @NewVoucherAmount = (@NewVoucherAmount * @Rate_VoucherCurrency);

											INSERT INTO @tbl_voucher
											EXEC [guest].[spALTERGuestVoucher] @VoucherReservationID, @NewVoucherAmount, @DrawerID, @UserID, @ValidFrom, @ValidTo

											SET @VoucherNumber = (SELECT VoucherNumber FROM @tbl_voucher);			
										
											SET @Message = 'The voucher has been redeemed successfully. ' + @ReservationCurrency + CAST(CAST(@VoucherAmount as decimal(18,2)) as varchar(20)) 
											+ ' has been added to the folio. And new voucher no: ' + CAST(@VoucherNumber as varchar(20)) + ' has been generated.';							
										END
									ELSE
										BEGIN
											SET @Message = 'The voucher has been redeemed successfully. ' + @ReservationCurrency + CAST(CAST(@VoucherAmount as decimal(18,2)) as varchar(20)) 
											+ ' has been added to the folio.';	
										END
																							
									SET @IsSuccess = 1;	
									
									DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
									DECLARE @Title varchar(200) = 'Redeem Guest Voucher: ' + 'Voucher no ' + (SELECT VoucherNumber FROM guest.Voucher WHERE VoucherID = @VoucherID)
									+ ' has redeemed for folio ' + (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
									+ (SELECT CAST(FolioNumber as varchar) FROM reservation.Reservation WHERE ReservationID = @ReservationID)
									+' '+ @ReservationCurrency + CAST(CAST(@VoucherAmount as decimal(18,2)) as varchar(20));
									DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID:' + CAST(@UserID as varchar(10));
									EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc		
								END
							ELSE
								BEGIN
									SET @Message = 'The transaction has been failed. The selected folio balance is zero.';														
									SET @IsSuccess = 0;
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
										
							IF(@NewVoucherAmount > 0.1)
								BEGIN
									SET @Message = 'The voucher has been redeemed successfully. ' + @ReservationCurrency + CAST(CAST(@VoucherAmount as decimal(18,2)) as varchar(20)) 
									+ ' has been added to the folio. And new voucher no: ' + CAST(@VoucherNumber as varchar(20)) + ' has been generated.';							
								END
							ELSE
								BEGIN
									SET @Message = 'The voucher has been redeemed successfully. ' + @ReservationCurrency + CAST(CAST(@VoucherAmount as decimal(18,2)) as varchar(20)) 
									+ ' has been added to the folio.';	
								END

							SET @IsSuccess = 1; --success
						END;  

						---------------------------- Insert into activity log---------------	
						DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
						EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
					END CATCH;
				END
			ELSE
				BEGIN
					SET @Message = 'Invalid guest voucher.';														
			        SET @IsSuccess = 0;
				END
		END
	ELSE
		BEGIN
			SET @Message = 'The transaction has been failed. The accounting date is not active.';														
			SET @IsSuccess = 0;
		END

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END

