Create PROCEDURE [reservation].[CheckInTrans_BKP310124]
(	
	@ReservationID int,
	@DrawerID int,
	@UserID int,
	@GuestID int,
	@ActualCheckIn datetime,
	@RoomChargeEffectFrom date,
	@CompanyID int,
	@BellBoyID int,
	@CheckInRooms as [reservation].[CheckInRooms] readonly,
	@EmrContactID int = 0,	
    @EmrContactName varchar(100),
    @EmrContactNumber varchar(15),
    @EmrContactRelation varchar(150),
	@IsActive bit = 1
	--@IsSplitInvoice bit=0
)
AS
BEGIN
	SET XACT_ABORT ON;

	DECLARE @GuestName varchar(250);
	DECLARE @TagQRCode varchar(500);
	DECLARE @Rooms varchar(100);
	DECLARE @CurrencyID int ;
	DECLARE @CheckInDateId int ;
	DECLARE @CheckOutDateId int ;
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
	DECLARE @FolioNo int; --Added for @TagQRCode
	
	SELECT @ExpectedCheckOut = r.ExpectedCheckOut, 
	@ExpectedCheckIn = r.ExpectedCheckIn,
	@ReservationStatusID = r.ReservationStatusID, 
	@ReservationTypeID = r.ReservationTypeID, 
	@CurrencyID = CurrencyID,
	@FolioNo=r.FolioNumber  -- Added for QR code
	FROM reservation.Reservation r
	WHERE r.ReservationID = @ReservationID

	SET @CheckInDateId  = (SELECT CAST(FORMAT(@ExpectedCheckIn,'yyyyMMdd') as int));
	SET @CheckOutDateId = (SELECT CAST(FORMAT(@ExpectedCheckOut,'yyyyMMdd') as int));

	DECLARE @Nights int = (SELECT DATEDIFF(day, @RoomChargeEffectFrom, CONVERT(DATE,@ExpectedCheckOut)));

	--IF(DATEDIFF(DAY, @RoomChargeEffectFrom, @ExpectedCheckOut) <= 0 OR DATEDIFF(DAY, @ActualCheckIn, @ExpectedCheckOut) <= 0)
	IF(DATEDIFF(DAY, @RoomChargeEffectFrom, @ExpectedCheckOut) <= 0 OR DATEDIFF(DAY, @ActualCheckIn, @ExpectedCheckOut) < 0)
	BEGIN
		--SET @Message = 'Room charge effect from date and actual check-in date must be earlier that expected check-out date.';
		SET @Message = 'Reservation cannot be check-in!<br><br>The actual check-in date must be earlier than the expected check-out date and Time!';
		SET @IsSuccess = 0; --Error	

		SET @LocationID = (SELECT LocationID FROM [app].[Drawer] WHERE DrawerID = @DrawerID);   --Added By Somnath
		EXEC [app].[spInsertActivityLog]22,@LocationID,@Message,@UserID	     --Added By Somnath

		SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
		Return;
	END

	SET @AccountingDateID = (SELECT [account].[GetAccountingDateIsActive] (@DrawerID));
	SET @LocationID = (SELECT LocationID FROM [app].[Drawer] WHERE DrawerID = @DrawerID);	

	SELECT @MainCurrencyID = MainCurrencyID, @RateCurrencyID = RateCurrencyID
	FROM general.[Location]
	WHERE LocationID = @LocationID	

	SET @TransactionFactor = (SELECT TransactionFactor FROM account.TransactionType WHERE TransactionTypeID = @TransactionTypeID);
	--SET @Comment = '@ActualCheckIn -> ' + CAST(@ActualCheckIn as varchar(25)) + ', @RoomChargeEffectFrom -> ' + CAST(@RoomChargeEffectFrom as varchar(25)) + ', ServerDateTime -> ' + CAST(GETDATE() as varchar(30));
	SET @Comment = '@ActualCheckIn -> ' + CAST(@ActualCheckIn as varchar(25)) + ', @RoomChargeEffectFrom -> ' + CAST(@RoomChargeEffectFrom as varchar(25)) + ', ServerDateTime -> ' + CAST(dbo.GetDatetimeBasedonTimezone( GETDATE()) as varchar(30));
	
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
									--IF NOT EXISTS(SELECT * FROM [room].[fnCheckIfRoomAvailableByReservation](@ActualCheckInID, @ExpectedCheckOutID, @ReservationID))
									--	BEGIN
											UPDATE reservation.Reservation
											SET ReservationStatusID = 3 --In-House
											,ActualCheckIn = @ActualCheckIn
											,GuestID = @GuestID
											--,CompanyID = @CompanyID
											,RoomChargeEffectDate = @RoomChargeEffectFrom
											,Nights = @Nights
											--,IsSplitInvoice=@IsSplitInvoice
											WHERE ReservationID = @ReservationID

											--UPDATE room.RoomStatusHistory
											--SET RoomStatusID = 5
											--,FromDateID = @RoomChargeEffectFromID
											--,FromDate = @RoomChargeEffectFrom
											--WHERE ReservationID = @ReservationID															

											DECLARE @CheckInDiff int = (SELECT DATEDIFF(DAY, @RoomChargeEffectFrom, @ExpectedCheckIn));
											DECLARE @DateID int;
											DECLARE @CheckInDiff2 int = @CheckInDiff;

											--------------------------------
											---RoomStatusHistory ?
											---RateID ?
											---@RoomChargeEffectFrom ?


											--INSERT INTO [reservation].[ReservedRoom]
											--([ReservationID],[RoomID],[StandardCheckInOutTimeID],[IsActive],[RateCurrencyID])
											--SELECT @ReservationID, CR.RoomID, 1, 1, @CurrencyID					
											--FROM @CheckInRooms CR 

											--WHERE t.RoomID = @RoomID
											  INSERT INTO [reservation].[ReservedRoom]
												([ReservationID], [RoomID], [StandardCheckInOutTimeID], [IsActive], [RateCurrencyID])
												SELECT @ReservationID, CR.RoomID, 1, 1, @CurrencyID
												FROM @CheckInRooms CR
												WHERE NOT EXISTS (SELECT 1FROM [reservation].[ReservedRoom] RRR WHERE RRR.ReservationID = @ReservationID )--AND RRR.RoomID = CR.RoomID);


												------Insert into Guest Ledger ------------------
												Insert Into [account].[GuestLedgerDetails] 
												(FolioNo,TransDate, ServiceId, TransRefNo, AmtBeforeTax,
												AmtAfterTax,TaxId,TaxPer,PaidStatus,TransStatus,
												Remarks,IsActive,CreatedBy,CreatedOn,AmtTax,IsComplimentary,ComplimentaryPercentage
												,UnitPriceBeforeDiscount
												,Discount
												,DiscountPercentage)
												--SELECT rr.FolioNumber,--rd.NightDate,
												--CONVERT(DATETIME, CONVERT(VARCHAR, rd.NightDate, 23) + ' ' + CONVERT(VARCHAR, GETDATE(), 108), 121) AS NightDate,
												--18,rr.ReservationID,rd.linetotal-rd.totaltaxamount,
												--rd.linetotal,3,10,0,1,
												--concat('Room Charges, ',[reservation].[fnGetReserveredRoom](rr.ReservationID),', ', format(rd.NightDate,'MMM-dd')),
												--1,85,GETDATE(),rd.totaltaxamount,
												--CASE rr.ReservationTypeID when 10 then 1 end  
												--,CASE rr.ReservationTypeID when 10 then 100 end  
												--,UnitPriceBeforeDiscount
												--,Discount
												--,rd.DiscountPercentage
												--FROM RESERVATION.Reservation rr
												--INNER JOIN reservation.reservationdetails rd on rr.ReservationID=rd.ReservationID
												--WHERE rr.ReservationStatusID=3 and 
												--format(rd.NightDate,'yyyy-MM-dd')<=FORMAT( GETDATE(),'yyyy-MM-dd')
												--and rd.ReservationID = @ReservationID 
												SELECT rr.FolioNumber,--rd.NightDate,
												CONVERT(DATETIME, CONVERT(VARCHAR, rd.NightDate, 23) + ' ' + CONVERT(VARCHAR, GETDATE(), 108), 121) AS NightDate,
												18,rr.ReservationID,(rd.linetotal-rd.totaltaxamount)/rd.Rooms,rd.linetotal/rd.Rooms,
												3,10,0,1,
												--concat('Room Charges, ',[reservation].[fnGetReserveredRoom](rr.ReservationID),', ', format(rd.NightDate,'MMM-dd')),
												concat('Room Charges , ',pr.RoomNo,', ', format(rd.NightDate,'MMM-dd')),
												1,85,GETDATE(),rd.totaltaxamount/rd.Rooms,
												CASE rr.ReservationTypeID when 10 then 1 end  
												,CASE rr.ReservationTypeID when 10 then 100 end  
												,rd.UnitPriceBeforeDiscount/rd.Rooms
												,rd.Discount
												,rd.DiscountPercentage
												FROM RESERVATION.Reservation rr
												INNER JOIN reservation.reservationdetails rd on rr.ReservationID=rd.ReservationID
												INNER JOIN [reservation].[ReservedRoom] rrr on rd.ReservationID=rrr.ReservationID
												INNER JOIN Products.Room pr on rrr.RoomID=pr.RoomID
												WHERE rr.ReservationStatusID=3 and format(rd.NightDate,'yyyy-MM-dd')=FORMAT( GETDATE(),'yyyy-MM-dd')
												and rd.ReservationID=@ReservationID
												and rr.FolioNumber not in (select FolioNo from 
													[account].[GuestLedgerDetails]  where FolioNo=rr.FolioNumber  
													and ServiceId=18 and format(TransDate,'yyyy-MM-dd')=FORMAT( GETDATE(),'yyyy-MM-dd'))
												
											
												-----------------End---------------------------

														----SET @ReservedRoomID = SCOPE_IDENTITY();							

														----IF(@ReservationTypeID = 7)	--HOUSE USE							
														----	BEGIN
														----		INSERT INTO [reservation].[RoomRate]
														----		([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
														----		SELECT @ReservedRoomID, r.DateID, 230, 0, 1
														----		FROM @dtRate r
														----		WHERE r.RoomID = @RoomID
														----	END							
														----ELSE								
														----	BEGIN
														----		INSERT INTO [reservation].[RoomRate]
														----		([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
														----		SELECT @ReservedRoomID, r.DateID, r.RateID, r.Amount, @DiscountID
														----		FROM @dtRate r
														----		WHERE r.RoomID = @RoomID
														----END	

														---------------------------------

														--IF(@CheckInDiff > 0)
														--	BEGIN
														--		WHILE(@CheckInDiff > 0)
														--		BEGIN
														--			SET @DateID = (CAST(FORMAT(@RoomChargeEffectFrom,'yyyyMMdd') as INT));

														--			INSERT INTO [reservation].[RoomRate]
														--			([ReservedRoomID], [RateID], [DateID], [Rate], [IsActive], [IsVoid], [DiscountID]) 
														--			SELECT rat.[ReservedRoomID], rat.[RateID], @DateID, rat.Rate, 1, 0, rat.[DiscountID]
														--			FROM [reservation].[RoomRate] rat
														--			INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID
														--			WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rr.IsActive = 1 AND rat.DateID = (CAST(FORMAT(@ExpectedCheckIn,'yyyyMMdd') as INT))

														--			SET @RoomChargeEffectFrom = DATEADD(DAY, 1, @RoomChargeEffectFrom);
														--			SET @CheckInDiff -= 1;
														--		END
														--	END
														--ELSE IF(@CheckInDiff < 0)
														--	BEGIN
														--		UPDATE rat
														--		SET rat.IsActive = 0
														--		FROM [reservation].[RoomRate] rat
														--		INNER JOIN reservation.ReservedRoom rr ON rat.ReservedRoomID = rr.ReservedRoomID
														--		WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rr.IsActive = 1 AND rat.DateID < @RoomChargeEffectFromID
														--	END											
											
											--- Enable when exchange rate is add in table
											--INSERT INTO [guest].[GuestWallet]
											--([GuestID],[TransactionTypeID],[AccountTypeID],[ReservationID],[ReservedRoomRateID],[DateID],[Amount],[RateCurrencyID]
											--,[AccountingDateID],[TransactionDateTime],[Remarks])
											--SELECT @GuestID, @TransactionTypeID, @AccountTypeID, rr.[ReservationID], rat.ReservedRoomRateID, rat.[DateID], (rat.Rate * @TransactionFactor)
											--,rr.RateCurrencyID,  @AccountingDateID, GETDATE(), @Remarks
											--FROM currency.vwCurrentExchangeRate vwc
											--INNER JOIN reservation.ReservedRoom rr ON vwc.CurrencyID = rr.RateCurrencyID AND vwc.DrawerID = @DrawerID
											--INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID
											--WHERE rr.ReservationID = @ReservationID AND rr.IsActive = 1 AND rat.IsActive = 1

											If EXISTS(Select RoomID From [reservation].[ReservedRoom] where ReservationID=@ReservationID)
											BEGIN
											UPDATE [Products].[Room] SET [RoomStatusID] = 5 where RoomID In (Select RoomID From [reservation].[ReservedRoom] where ReservationID=@ReservationID)
											END
											ELSE
											BEGIN
											UPDATE [Products].[Room] SET [RoomStatusID] = 5 --In House
											WHERE RoomID in(SELECT RoomID FROM @CheckInRooms)
											END

											INSERT INTO [reservation].[ReservationStatusLog]
											([ReservationID],[ReservationStatusID],[UserID],[DateTime], [Remarks])
											VALUES(@ReservationID, 3, @UserID, GETDATE(), @Comment)
											---------
											
											--INSERT INTO [Products].[RoomLogs]
											--([SubCategoryID],[ItemID],[RoomID],[BookingDate],[Cancelled],[Createdby],[CreateDate])
											--SELECT CR.SubCategoryID,CR.ItemID,CR.RoomID,@RoomChargeEffectFrom,0,@UserID, GETDATE()
											--FROM @CheckInRooms CR

											INSERT INTO [Products].[RoomLogs]
											([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate], [ReservationID],[CreatedBy],[CreateDate])	
											SELECT RoomID, @ActualCheckInID, @ExpectedCheckOutID, 5, 1, @ActualCheckIn, @ExpectedCheckOut,@ReservationID, @UserID,GETDATE()
											FROM [reservation].[ReservedRoom]
											WHERE ReservationID = @ReservationID AND IsActive = 1
											----------										

											---Create Luggage QR code
											SELECT @GuestName= FirstName from [contact].[Details]  where ContactID = (select top 1(ContactID) from [guest].[Guest] where GuestID = @GuestID)
											SELECT @Rooms= COALESCE(@Rooms + '-', '') + CAST(R.RoomNo AS VARCHAR(5))
											FROM @CheckInRooms CR inner join [Products].[Room] R on CR.RoomID = R.RoomID

											--SET @TagQRCode = UPPER(TRIM((STR(RAND() * (899999) + 100000))) +'-' + @GuestName + '-' + @Rooms +'-'+  CONVERT(NVARCHAR, @CheckInDateId, 0))
											--SET @TagQRCode = 'Folio No:' + ISNULL(@FolioNo, 'N/A') + '-' + 'Name:' + ISNULL(@GuestName, 'N/A') + '-' + 'Room No:' + ISNULL(@Rooms, 'N/A');
											SET @TagQRCode ='FOLIO NO:' + CONVERT(NVARCHAR, @FolioNo, 0) + '-' + 'NAME:'+ UPPER(@GuestName) + '-' + 'ROOM NO:' + @Rooms
											----------Add Bellboy details------------------------
											
											exec [guest].[usp_GuestLuggage_Insert] @ReservationID, @BellBoyID,@UserID,1,@GuestID,3,@TagQRCode

											----------Add Emergency contact details------------------------
											
											exec [contact].[EmergencyContactIU] @EmrContactID,@ReservationID,@EmrContactName,@EmrContactNumber,@EmrContactRelation,@UserID,@LocationID,@IsActive
											----------------------------------

											SET @IsSuccess = 1; --Success
											SET @Message = 'Check-in has been successful for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.';

											DECLARE @Folio varchar(50) = (SELECT CONCAT(LocationCode, FolioNumber) FROM reservation.Reservation r
											INNER JOIN general.Location l ON r.LocationID = l.LocationID
											WHERE r.ReservationID = @ReservationID)
											DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
											DECLARE @Title varchar(200) = 'Check In for ReservationID- ' + Cast(@ReservationID AS varchar(20))+ ' '   +(SELECT FirstName + ' ' + ISNULL(LastName, '') FROM guest.Guest g
											INNER JOIN contact.Details d ON g.ContactID = d.ContactID
											WHERE GuestID = @GuestID) + ', And Folio No- (' + @Folio + ')' + ' has been Successfully completed.'
											DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
											EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
									--	END
									--ELSE
									--	BEGIN
									--		SET @Message = 'Room not available for actual check-in date <b>' + FORMAT(@ActualCheckIn,'dd-MMM-yyyy') +'</b>.';
									--		SET @IsSuccess = 0; --Error
									--	END

									Declare @Activity nvarchar(MAX)= @NotDesc			                 	  -- Added By Somnath
									EXEC [app].[spInsertActivityLog]22,@LocationID,@Activity,@UserID,@Title   -- Added By Somnath

										-- added by vasanth
									DECLARE @OutputSequenceNo  VARCHAR(255);
									EXEC [report].spGetReportSequenceNo @DocTypeId = 2, @SequenceNo = @OutputSequenceNo OUTPUT;

									INSERT INTO [reservation].[ProformaInvoice](
									 [DocumentTypeId]
									,[ReservationId]
									,[ProformaInvoiceNo]
									,[CreatedDate]
									,[CreatedBy])
									VALUES
									(2,@ReservationID,@OutputSequenceNo,GETDATE(),@UserID)

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
								EXEC [app].[spInsertActivityLog]22,@LocationID,@Act,@UserID	,@Message   --- "	,@Message" Added By Somnath
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
 