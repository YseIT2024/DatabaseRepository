CREATE PROCEDURE [reservation].[spCheckInToReserved] --5124,1,85
(	
	@ReservationID int,
	@UserID int,
	@DrawerID int
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
	
	IF(@ReservationStatusID = 3)---InHouse
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
											SET @Message = ' Reservation has been Reversed from Check-in to Reserved Status successfully for Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' .';

											DECLARE @Folio varchar(50) = (SELECT CONCAT(LocationCode, FolioNumber) FROM reservation.Reservation r
											INNER JOIN general.Location l ON r.LocationID = l.LocationID
											WHERE r.ReservationID = @ReservationID)
											DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
											DECLARE @Title varchar(200) = 'Check In for ReservationID- ' + Cast(@ReservationID AS varchar(20))+ ' '   +(SELECT FirstName + ' ' + ISNULL(LastName, '') FROM guest.Guest g
											INNER JOIN contact.Details d ON g.ContactID = d.ContactID
											WHERE GuestID = @GuestID) + ', And Folio No- (' + @Folio + ')' + ' has been Successfully completed.'
											DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
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
									SET @Message = 'Check-in has been successful for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.';
								END;  
		
								---------------------------- Insert into activity log---------------	
								DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
								EXEC [app].[spInsertActivityLog]22,@LocationID,@Act,@UserID	,@Message   --- "	,@Message" Added By Somnath
							END CATCH;  						
						END
	ELSE
		BEGIN
			SET @IsSuccess = 0;		
			SET @Message = 'Someone has change the status of Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' Please refresh the page.';
		END
	
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END
 