
CREATE PROCEDURE [reservation].[spDoCheckIn]
(	
	@ReservationID int,
	@DrawerID int,
	@UserID int,
	@GuestID int,
	@ActualCheckIn datetime,
	@RoomChargeEffectFrom date,
	@CompanyID int
)
AS
BEGIN
	SET XACT_ABORT ON;
		
	DECLARE @ReservationTypeID int;
	DECLARE @ReservationStatusID int;
	DECLARE @MainCurrencyID int;	
	DECLARE @TransactionFactor int; 
	DECLARE @LocationID int;
	DECLARE @RateCurrencyID int;	
	DECLARE @ExpectedCheckOut datetime;	
	DECLARE @ExpectedCheckIn datetime;
	DECLARE @AccountingDateID int;	
	DECLARE @Comment varchar(250);
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @AccountTypeID int = 82;
	DECLARE @Remarks varchar(max) = 'Daily room charge.';	
	DECLARE @TransactionTypeID int = 1;
	DECLARE @RoomChargeEffectFromID int = (CAST(FORMAT(@RoomChargeEffectFrom,'yyyyMMdd') as int));
	
	SELECT @ExpectedCheckOut = r.ExpectedCheckOut, @ExpectedCheckIn = r.ExpectedCheckIn, @ReservationStatusID = r.ReservationStatusID, @ReservationTypeID = r.ReservationTypeID 
	FROM reservation.Reservation r
	WHERE r.ReservationID = @ReservationID

	DECLARE @Nights int = (SELECT DATEDIFF(day, @RoomChargeEffectFrom, CONVERT(DATE,@ExpectedCheckOut)));

	IF(DATEDIFF(DAY, @RoomChargeEffectFrom, @ExpectedCheckOut) <= 0 OR DATEDIFF(DAY, @ActualCheckIn, @ExpectedCheckOut) <= 0)
	BEGIN
		--SET @Message = 'Room charge effect from date and actual check-in date must be earlier that expected check-out date.';
		SET @Message = 'Reservation cannot be check-in!<br><br>The actual check-in date must be earlier than the expected check-out date!';
		SET @IsSuccess = 0; --Error	

		SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
		Return;
	END

	SET @AccountingDateID = (SELECT [account].[GetAccountingDateIsActive] (@DrawerID));
	SET @LocationID = (SELECT LocationID FROM [app].[Drawer] WHERE DrawerID = @DrawerID);	

	SELECT @MainCurrencyID = MainCurrencyID, @RateCurrencyID = RateCurrencyID
	FROM general.[Location]
	WHERE LocationID = @LocationID	

	SET @TransactionFactor = (SELECT TransactionFactor FROM account.TransactionType WHERE TransactionTypeID = @TransactionTypeID);
	SET @Comment = '@ActualCheckIn -> ' + CAST(@ActualCheckIn as varchar(25)) + ', @RoomChargeEffectFrom -> ' + CAST(@RoomChargeEffectFrom as varchar(25)) + ', ServerDateTime -> ' + CAST(GETDATE() as varchar(30));

	IF(@ReservationStatusID = 1)---Reserved
		BEGIN
			IF(@AccountingDateID > 0 AND @AccountingDateID IS NOT NULL)
				BEGIN			
					IF(DATEDIFF(DAY, @ActualCheckIn, @ExpectedCheckOut) >= 0)
						BEGIN
							DECLARE @ActualCheckInID int = (CAST(FORMAT(@ActualCheckIn,'yyyyMMdd') as int));
							DECLARE @ExpectedCheckOutID int = (CAST(FORMAT(@ExpectedCheckOut,'yyyyMMdd') as int));
					
							BEGIN TRY  
								BEGIN TRANSACTION
									IF NOT EXISTS(SELECT * FROM [room].[fnCheckIfRoomAvailableByReservation](@ActualCheckInID, @ExpectedCheckOutID, @ReservationID))
										BEGIN
											UPDATE reservation.Reservation
											SET ReservationStatusID = 3
											,ActualCheckIn = @ActualCheckIn
											,GuestID = @GuestID
											--,CompanyID = @CompanyID
											,RoomChargeEffectDate = @RoomChargeEffectFrom
											,Nights = @Nights
											WHERE ReservationID = @ReservationID

											UPDATE room.RoomStatusHistory
											SET RoomStatusID = 5
											,FromDateID = @RoomChargeEffectFromID
											,FromDate = @RoomChargeEffectFrom
											WHERE ReservationID = @ReservationID															

											DECLARE @CheckInDiff int = (SELECT DATEDIFF(DAY, @RoomChargeEffectFrom, @ExpectedCheckIn));
											DECLARE @DateID int;
											DECLARE @CheckInDiff2 int = @CheckInDiff;

											IF(@CheckInDiff > 0)
												BEGIN
													WHILE(@CheckInDiff > 0)
													BEGIN
														SET @DateID = (CAST(FORMAT(@RoomChargeEffectFrom,'yyyyMMdd') as INT));

														INSERT INTO [reservation].[RoomRate]
														([ReservedRoomID], [RateID], [DateID], [Rate], [IsActive], [IsVoid], [DiscountID]) 
														SELECT rat.[ReservedRoomID], rat.[RateID], @DateID, rat.Rate, 1, 0, rat.[DiscountID]
														FROM [reservation].[RoomRate] rat
														INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID
														WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rr.IsActive = 1 AND rat.DateID = (CAST(FORMAT(@ExpectedCheckIn,'yyyyMMdd') as INT))

														SET @RoomChargeEffectFrom = DATEADD(DAY, 1, @RoomChargeEffectFrom);
														SET @CheckInDiff -= 1;
													END
												END
											ELSE IF(@CheckInDiff < 0)
												BEGIN
													UPDATE rat
													SET rat.IsActive = 0
													FROM [reservation].[RoomRate] rat
													INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID
													WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rr.IsActive = 1 AND rat.DateID < @RoomChargeEffectFromID
												END											
															
											INSERT INTO [guest].[GuestWallet]
											([GuestID],[TransactionTypeID],[AccountTypeID],[ReservationID],[ReservedRoomRateID],[DateID],[Amount],[RateCurrencyID]
											,[AccountingDateID],[TransactionDateTime],[Remarks])
											SELECT @GuestID, @TransactionTypeID, @AccountTypeID, rr.[ReservationID], rat.ReservedRoomRateID, rat.[DateID], (rat.Rate * @TransactionFactor)
											,rr.RateCurrencyID,  @AccountingDateID, GETDATE(), @Remarks
											FROM currency.vwCurrentExchangeRate vwc
											INNER JOIN reservation.ReservedRoom rr ON vwc.CurrencyID = rr.RateCurrencyID AND vwc.DrawerID = @DrawerID
											INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID
											WHERE rr.ReservationID = @ReservationID AND rr.IsActive = 1 AND rat.IsActive = 1

											INSERT INTO [reservation].[ReservationStatusLog]
											([ReservationID],[ReservationStatusID],[UserID],[DateTime], [Remarks])
											VALUES(@ReservationID, 3, @UserID, GETDATE(), @Comment)

											SET @IsSuccess = 1; --Success
											SET @Message = 'Check-in has been successful for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.';

											DECLARE @Folio varchar(50) = (SELECT CONCAT(LocationCode, FolioNumber) FROM reservation.Reservation r
											INNER JOIN general.Location l ON r.LocationID = l.LocationID
											WHERE r.ReservationID = @ReservationID)
											DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
											DECLARE @Title varchar(200) = 'Check In: ' + (SELECT FirstName + ' ' + ISNULL(LastName, '') FROM guest.Guest g
											INNER JOIN contact.Details d ON g.ContactID = d.ContactID
											WHERE GuestID = @GuestID) + '(' + @Folio + ')' + ' has Checked-In'
											DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
											EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
										END
									ELSE
										BEGIN
											SET @Message = 'Room not available for actual check-in date <b>' + FORMAT(@ActualCheckIn,'dd-MMM-yyyy') +'</b>.';
											SET @IsSuccess = 0; --Error
										END
								COMMIT TRANSACTION
							END TRY  
							BEGIN CATCH    
								IF (XACT_STATE() = -1) 
								BEGIN  			
									ROLLBACK TRANSACTION;  

									SET @Message = ERROR_MESSAGE();
									SET @IsSuccess = 0; --Error			
								END;    
    
								IF (XACT_STATE() = 1)  
								BEGIN  			
									COMMIT TRANSACTION;   

									SET @IsSuccess = 1; --Success  
									SET @Message = 'Check-in has been successful for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.';
								END;  
		
								---------------------------- Insert into activity log---------------	
								DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
								EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
							END CATCH;  						
						END
					ELSE
						BEGIN
							SET @Message = 'The actual check-in date can not be greater than the expected check-out date.';
							SET @IsSuccess = 0; --Error
						END
				END
			ELSE	
				BEGIN
					SET @Message = 'Accounting date is not active. Please open new accounting date.';
					SET @IsSuccess = 0; --Error	
				END
		END
	ELSE
		BEGIN
			SET @IsSuccess = 0;		
			SET @Message = 'Someone has change the status of Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' Please refresh the page.';
		END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END
