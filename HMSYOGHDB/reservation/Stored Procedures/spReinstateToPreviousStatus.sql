CREATE PROCEDURE [reservation].[spReinstateToPreviousStatus] --5124,1,85
(	
	@ReservationID int,
	@UserID int,
	@DrawerID int,
	@StatusID int 
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
		DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';
		DECLARE @StatusCode int = 0;
		DECLARE @RSHistoryID int;
	DECLARE @MainCurrencyID int;	
	DECLARE @TransactionFactor int; 
	DECLARE @LocationID int;
	DECLARE @RateCurrencyID int;	
	DECLARE @ExpectedCheckOut datetime;	
	DECLARE @ExpectedCheckIn datetime;
	DECLARE @AccountingDateID int;	
	DECLARE @Comment varchar(250);
	DECLARE @AccountTypeID int = 82;
	DECLARE @Remarks varchar(max) = 'Daily room charge.';	
	DECLARE @TransactionTypeID int = 1;
	--DECLARE @RoomChargeEffectFromID int = (CAST(FORMAT(@RoomChargeEffectFrom,'yyyyMMdd') as int));
	DECLARE @FolioNo int= (Select FolioNumber From reservation.Reservation Where ReservationID = @ReservationID); --Added for @TagQRCode
	Declare @GuestID int = (Select GuestID From reservation.Reservation Where ReservationID = @ReservationID)
	
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


	SET @LocationID = (SELECT LocationID FROM [app].[Drawer] WHERE DrawerID = @DrawerID);	

	

	SET @TransactionFactor = (SELECT TransactionFactor FROM account.TransactionType WHERE TransactionTypeID = @TransactionTypeID);
	SET @Comment = 'The Reservation has been reversed from InHouse to Reserved. On ' + ', ServerDateTime -> ' + CAST(dbo.GetDatetimeBasedonTimezone( GETDATE()) as varchar(30))+' By UserID- '+Cast(@UserID As Varchar(20));
	IF((SELECT top 1 ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID) <> @StatusID)
	Begin

	SELECT 0 AS [IsSuccess], 'Status has been changed from outside, Please refresh the page and try again!' AS [Message];
	return;

	End
	Else
	Begin

	IF((SELECT top 1 ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID) = 1) --Reserved
			Begin

				BEGIN TRY	
	
							SET @LocationID = (Select LocationID from [reservation].[Reservation] where ReservationID = @ReservationID)
							DECLARE @LocationCode VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
							--SET @FolioNumber = (SELECT [reservation].[fnGenerateFolioNumber](@LocationID));
							--If(@TaxRefNo IS NOT NULL)
				   --          BEGIN
							--	  INSERT INTO reservation.TaxExemptionDetails (TaxRefNo, CreatedDate, UserId, ReservationID)
							--	  VALUES (@TaxRefNo, GETDATE(), @UserID, @ReservationID);
							--	-- Retrieve the identity value of the inserted row
							--	-- SET @TaxExemptionDetailsId = SCOPE_IDENTITY();
					
							--	----------Added By Somnath---------------
							--	SET @Message ='New TAX Certificate created successfully';
							--	Declare  @Acts nVarchar(MAX) = 'New TAX Certificate created successfully for the ReservationID- : '+ Cast(@ReservationID AS Varchar(20))+ ' And Folio No. As- '+  Cast(@FolioNumbers AS Varchar(20)) + ' With tax Reference No As ' +Cast(@TaxRefNo AS Varchar(20))+ ' On Date- ' +  Cast(GETDATE() AS Varchar(20))+' By UserID- '+Cast(@UserID AS Varchar(20));
							--		EXEC [app].[spInsertActivityLog] 40,@LocationID,@Acts,@UserID,@Message
							--	----------Added By Somnath---------------

				   --          END	

							UPDATE [reservation].[Reservation]
								SET ReservationStatusID = 12 --Requested
								, FolioNumber = @FolioNo
								WHERE  ReservationID = @ReservationID

								 INSERT INTO [reservation].[ReservationStatusLog]
										 ([ReservationID],ReservationStatusID,Remarks,UserID,DateTime,ReservedRoomRateID)
										 VALUES (@ReservationID,1,'ReinstatedFromReservedToRequested',@UserID,GETDATE(),0)
						 
								declare @TotalAmountBeforeTax decimal(18,2)
								declare @TotalAmountAfterTax decimal(18,2)

								select @TotalAmountBeforeTax=TotalAmountBeforeTax, @TotalAmountAfterTax=TotalAmountAfterTax from reservation.Reservation where ReservationID=@ReservationID

					
							
							
										--DECLARE @CurrencyID INT;

								SET @CurrencyID = (SELECT CurrencyID FROM reservation.Reservation WHERE ReservationID = @ReservationID);

								-- Check if the reservation already has allocated rooms
								IF EXISTS (SELECT 1 FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID)
								BEGIN
									-- If no existing records, then proceed to insert
									Delete From [reservation].[ReservedRoom] WHERE  ReservationID = @ReservationID
									Delete From [Products].[RoomLogs] WHERE  ReservationID = @ReservationID

									--DECLARE @ExpectedCheckIn DATE;
									--DECLARE @ExpectedCheckOut DATE;

									--SET @ExpectedCheckIn = (SELECT ExpectedCheckIn FROM reservation.Reservation WHERE ReservationID = @ReservationID);
									--SET @ExpectedCheckOut = (SELECT ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID = @ReservationID);

									--DECLARE @ExpectedCheckInID INT = (CAST(FORMAT(@ExpectedCheckIn, 'yyyyMMdd') AS INT));
									--DECLARE @ExpectedCheckOutID INT = (CAST(FORMAT(@ExpectedCheckOut, 'yyyyMMdd') AS INT));

									--INSERT INTO [Products].[RoomLogs]
									--(
									--	[RoomID], [FromDateID], [ToDateID], [RoomStatusID], [IsPrimaryStatus],
									--	[FromDate], [ToDate], [ReservationID], [CreatedBy], [CreateDate]
									--)
									--SELECT
									--	RoomID, @ExpectedCheckInID, @ExpectedCheckOutID, 2, 1, @ExpectedCheckIn,
									--	@ExpectedCheckOut, @ReservationID, @UserID, GETDATE()
									--FROM [reservation].[ReservedRoom]
									--WHERE ReservationID = @ReservationID AND IsActive = 1;
									END
														--UPDATE [Products].[Room] SET [RoomStatusID] = 2 --Reserved
														--WHERE RoomID in(SELECT RoomID FROM @CheckInRooms)
							

								--SET @FolioNumbers = @LocationCode + CONVERT(VARCHAR,@FolioNumber) 
								---
								--SET @FolioNo =@FolioNumber  ---DONE BY MURUGESH S  --
								SET @IsSuccess = 1; --success 
								SET @Message = 'Reservation  successfully Reversed from Reserved to Requested  for : ReservationID- ' + Cast(@ReservationID As varchar(20));	
								SET @Title = 'Reservation approved for : ReservationID- ' + Cast(@ReservationID As varchar(20))+' and the FolioNumbers  is : ' + Cast(@FolioNo as varchar(10)) ;	

								----------Added By Somnath---------------
					Set @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));

					EXEC [app].[spInsertActivityLog] 35,@LocationID,@NotDesc,@UserID,@Title
	            				----------Added By Somnath---------------
				END TRY  
				BEGIN CATCH    
					IF (XACT_STATE() = -1) 
					BEGIN  			
						--ROLLBACK TRANSACTION; 			
						SET @Message = ERROR_MESSAGE();			
						SET @IsSuccess = 0; --error			
					END; 		
		
					---------------------------- Insert into activity log---------------	
					DECLARE @Act VARCHAR(MAX)  = (SELECT app.fngeterrorinfo());		
					EXEC [app].[spInsertActivityLog] 35,@LocationID,@Act,@UserID,@Message	-- Changed By Somnath
				END CATCH;  

			SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNo AS [FolioNumber];
		END

	Else IF((SELECT top 1 ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID) = 3)---InHouse
		BEGIN		
							BEGIN TRY  
								BEGIN TRANSACTION
											UPDATE reservation.Reservation
											SET ReservationStatusID = 1 --Reserved
											,GuestID = @GuestID

											WHERE ReservationID = @ReservationID

											DECLARE @DateID int;


												------Updating Guest Ledger to Is Active Zero ------------------
												Update GLD Set GLD.IsActive=0
												FROM RESERVATION.Reservation rr
												JOin [account].[GuestLedgerDetails]  GLD ON GLD.FolioNo=rr.FolioNumber
												WHERE rr.ReservationStatusID=3  
												and rr.ReservationID = @ReservationID 
												------Updating Guest Ledger to Is Active Zero ------------------
												

											If EXISTS(Select RoomID From [reservation].[ReservedRoom] where ReservationID=@ReservationID)
											BEGIN
											UPDATE [Products].[Room] SET [RoomStatusID] = 2 where RoomID In (Select RoomID From [reservation].[ReservedRoom] where ReservationID=@ReservationID)
											END
											
											INSERT INTO [reservation].[ReservationStatusLog]
											([ReservationID],[ReservationStatusID],[UserID],[DateTime], [Remarks])
											VALUES(@ReservationID, 1, @UserID, GETDATE(), @Comment)											
											

											Update  [Products].[RoomLogs] Set [RoomStatusID]=2
											WHERE ReservationID = @ReservationID  AND IsPrimaryStatus=1									

											
											----------Deleting GuestLuggage details------------------------
											Delete From guest.GuestLuggage Where ReservationID= @ReservationID    --Deleting from table 

											
											Delete From [contact].[EmergencyContact]  Where ReservationID= @ReservationID    --Deleting from table 
											----------Deleting Emergency contact details------------------------
											----------------------------------

											SET @IsSuccess = 1; --Success
											SET @Message = ' Reservation has been Reversed from InHouse to Reserved Status successfully for Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' .';

											DECLARE @Folio varchar(50) = (SELECT CONCAT(LocationCode, FolioNumber) FROM reservation.Reservation r
											INNER JOIN general.Location l ON r.LocationID = l.LocationID
											WHERE r.ReservationID = @ReservationID)
											DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
											Set @Title = 'Check In for ReservationID- ' + Cast(@ReservationID AS varchar(20))+ ' '   +(SELECT FirstName + ' ' + ISNULL(LastName, '') FROM guest.Guest g
											INNER JOIN contact.Details d ON g.ContactID = d.ContactID
											WHERE GuestID = @GuestID) + ', And Folio No- (' + @Folio + ')' + ' has been Successfully completed.'
											Set @NotDesc  = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
											EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
									
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
									SET @Message = 'Reservation has been Reversed from InHouse to Reserved Status successfully for Reservation ID: ' + CAST(@ReservationID as varchar(12)) + '.';
								END;  
		
								---------------------------- Insert into activity log---------------	
								Set @Act  = (SELECT app.fngeterrorinfo());		
								EXEC [app].[spInsertActivityLog]22,@LocationID,@Act,@UserID	,@Message   --- "	,@Message" Added By Somnath
							END CATCH;  						
						END
	--ELSE
	--	BEGIN
	--		SET @IsSuccess = 0;		
	--		SET @Message = 'Someone has change the status of Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' Please refresh the page.';
	--	END

	else IF((SELECT top 1 ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID) = 4) --CheckedOut
		BEGIN					
			BEGIN TRY  
				BEGIN TRANSACTION
					
					

					UPDATE reservation.Reservation
					SET ReservationStatusID = 3 --InHouse
					,ActualCheckOut = Null
					--,CompanyID = @CompanyID				
					WHERE ReservationID = @ReservationID

					--SET @RSHistoryID = (SELECT MAX(RSHistoryID) FROM [Products].[RoomLogs] WHERE [ReservationID] = @ReservationID)

					UPDATE [Products].[Room]
					SET [RoomStatusID] = 5   --InHouse
					where [RoomID] in (SELECT [RoomID] FROM [reservation].[ReservedRoom] where [ReservationID] = @ReservationID AND IsActive=1);

					SET @RSHistoryID = (Select RSHistoryID From [Products].[RoomLogs] WHERE ReservationID=@ReservationID AND RoomStatusID=8 AND IsPrimaryStatus = 1) ;   --SCOPE_IDENTITY();

					UPDATE [Products].[RoomLogs]
					SET RoomStatusID = 5 --Checked Out
					,IsPrimaryStatus = 1
					
					WHERE ReservationID=@ReservationID And RoomStatusID = 8   ;-- RSHistoryID = @RSHistoryID   -- Changed By Somnath
					 

					 

					Delete From  [Products].[RoomLogs] WHERE ReservationID = @ReservationID AND RoomStatusID= 8 And IsPrimaryStatus=1 ;

					
					Delete From [todo].[ToDo] WHERE RSHistoryID= @RSHistoryID;
					
					Delete From [reservation].[ReservationStatusLog] WHERE ReservationID= @ReservationID And ReservationStatusID= 4;
					
					Delete From [reservation].[CheckOutDetail] Where  ReservationID= @ReservationID  ;
					

					Delete From guest.GuestLuggage Where ReservationID= @ReservationID  AND ReservationStatusID=4;
					
	         Delete From [reservation].[ReservationBalance] WHERE [ReservationID] = @ReservationID


			DECLARE @FolioNumber int;
			DECLARE @InvoiceID int;
			
			SELECT @FolioNumber=FolioNumber FROM reservation.Reservation WHERE ReservationID=@ReservationID
			SELECT @InvoiceID=InvoiceNo FROM reservation.Invoice WHERE FolioNumber=@FolioNumber

			Delete From  reservation.InvoiceDetails  Where InvoiceNo= @InvoiceID;
			Delete From  reservation.Invoice  Where InvoiceNo= @InvoiceID;

					------------------------------------

					
					SET @IsSuccess = 1; --Success
					SET @Message = 'Check Out has been successfully Reversed to InHouse for Reservation ID: ' + CAST(@ReservationID as varchar(12)) + '.' ;

					--DECLARE @Folio varchar(50); 
					DECLARE @Guest varchar(200);
					 
					SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
					 FROM reservation.Reservation r
					INNER JOIN general.Location l ON r.LocationID = l.LocationID
					INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
					INNER JOIN contact.Details d ON g.ContactID = d.ContactID
					WHERE r.ReservationID = 5124

					Set @Drawer = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
					Set @Title = 'Check Out Reversal for ReservationID: ' + CAST(@ReservationID as varchar(12)) + '. ' + @Guest + ', And Folio No(' + @Folio + ')' + ' has been completed successfully.'
					Set @NotDesc  = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc

				COMMIT TRANSACTION

				EXEC [app].[spInsertActivityLog] 23,@LocationID,@NotDesc,@UserID,@Message
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
					SET @Message = 'Check Out has been successfully Reversed to InHouse for Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' .';
				END;  
		
				---------------------------- Insert into activity log---------------	
				Set @Act  = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
			END CATCH;  			
		END
	--ELSE
	--BEGIN
	--	SET @IsSuccess = 0;
	--	SET @StatusCode = -1;
	--	SET @Message = 'Someone has change the status of Reservation ID: <b>#' + CAST(@ReservationID as varchar(12))  + '</b>, <br>Please refresh the page.';
	--END


	Else IF((SELECT ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID) in (15)) --No Show
	BEGIN
		BEGIN TRY  
			BEGIN TRANSACTION	
			DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)

				UPDATE [reservation].[Reservation]
				SET ReservationStatusID = 1 -- Reserved 			
				WHERE ReservationID = @ReservationID
			
				UPDATE [reservation].[CancellationDetail] 
				set [ReservationStatusID] = 16 -- ReInstate
				WHERE ReservationID = @ReservationID				
			
				INSERT INTO [reservation].[ReservationStatusLog]
				([ReservationID],[ReservationStatusID],[UserID],[DateTime])
				VALUES(@ReservationID, 1 -- Reserved 	
				, @UserID, GETDATE())

				SET @IsSuccess = 1; --Success
				SET @Message = 'No show has been updated to Re-Instate successfully.';

				SELECT @FolioNumber = FolioNumber FROM reservation.Reservation WHERE ReservationID = @ReservationID

				Set @Title = 'Re-Instate Reservation for ReservationID- '+ Cast(@ReservationID AS Varchar(20))+' and ' + (SELECT CONCAT(@Location, FolioNumber) FROM reservation.Reservation WHERE ReservationID = @ReservationID) 
				+cast(@FolioNumber As varchar(20))+ ' folio number completed successfully.'
				Set @NotDesc = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + ' By UserID- '+ Cast(@UserID AS Varchar(20))+' .' ;
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
			COMMIT TRANSACTION
			EXEC [app].[spInsertActivityLog]38,@LocationID,@NotDesc,@UserID, @Message	
		END TRY  
		BEGIN CATCH    
			IF (XACT_STATE() = -1) 
			BEGIN  			
				ROLLBACK TRANSACTION;  

				SET @Message = ERROR_MESSAGE();
				SET @IsSuccess = 0; --Error			
			END; 
		
			---------------------------- Insert into activity log---------------	
			Set @Act = (SELECT app.fngeterrorinfo());		
			EXEC [app].[spInsertActivityLog]38,@LocationID,@Act,@UserID, @Message	
		END CATCH;  
	END
	ELSE
		BEGIN
			SET @Message = 'An error occurred in database please refresh the page';
			SET @IsSuccess = 0; --Error		
		END


	
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END
 End