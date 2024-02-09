
CREATE Proc [reservation].[spDoEarlyCheckOut] --2044,5,1,8,0,150
(	
	@ReservationID int,
	@LocationID int,
	@UserID int,
	@DrawerID int,
	@VoucherAmount decimal(18,6) = 0,	
	@CompanyID int,
	@VoidDays int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON;  

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @StatusCode int = 0;
	DECLARE @CurrentDateId int;
	DECLARE @NextDayDateId int;		
	DECLARE @ActualCheckOut datetime = GETDATE();
	DECLARE @GuestID int;
	DECLARE @tbl_voucher TABLE([VoucherID] int,[VoucherNumber] varchar(50));
	DECLARE @VoucherNumber varchar(100) = '';
	DECLARE @ExpectedCheckOut date;	
	DECLARE @ReservedRoomRateID int;	
	DECLARE @Comment varchar(max);
	DECLARE @WalletID int;
	DECLARE @Init int = 1;
	DECLARE @RSHistoryID int;

	IF((SELECT ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID) = 3) --In House
		BEGIN
			SELECT @GuestID = GuestID, @ExpectedCheckOut = ExpectedCheckOut
			FROM reservation.Reservation
			WHERE ReservationID = @ReservationID AND LocationID = @LocationID
				
			BEGIN TRY  
				BEGIN TRANSACTION
					SET @CurrentDateId = CAST(FORMAT(@ActualCheckOut,'yyyyMMdd') as int);
					SET @NextDayDateId = CAST(FORMAT(DATEADD(DAY,1,@ActualCheckOut),'yyyyMMdd') as int);					

					UPDATE reservation.Reservation
					SET ReservationStatusID = 4 --Check Out
					,ActualCheckOut = @ActualCheckOut
					,CompanyID = @CompanyID			
					WHERE ReservationID = @ReservationID

					SET @RSHistoryID = (SELECT MAX(RSHistoryID) FROM room.RoomStatusHistory WHERE ReservationID = @ReservationID)

					UPDATE room.RoomStatusHistory
					SET RoomStatusID = 8 --Checked Out
					,IsPrimaryStatus = 0
					,ToDate = @ActualCheckOut
					,ToDateID = @CurrentDateId
					WHERE RSHistoryID = @RSHistoryID

					IF(@CompanyID = 0 AND @VoucherAmount > 0)
					BEGIN
						INSERT INTO @tbl_voucher
						EXEC [guest].[spALTERGuestVoucher] @ReservationID,@VoucherAmount,@DrawerID,@UserID,NULL,NULL

						SET @VoucherNumber = (SELECT VoucherNumber FROM @tbl_voucher);
					END

					INSERT INTO [room].[RoomStatusHistory]
					([RoomID], [FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[UserID])	
					SELECT RoomID, @CurrentDateId, @NextDayDateId, 3, 1, @ActualCheckOut, DATEADD(DAY,1,@ActualCheckOut), @UserID
					FROM [reservation].[ReservedRoom]
					WHERE ReservationID = @ReservationID AND IsActive = 1

					SET @StatusCode = SCOPE_IDENTITY();

					INSERT INTO [todo].[ToDo]
					([ToDoTypeID],[LocationID],[DueDateTime],[Description],[EnteredOn],[EnteredBy],[RSHistoryID],[IsCompleted])
					Values(1,@LocationID,DATEADD(DAY,1,@ActualCheckOut), 'Housekeeping after Checked Out', @ActualCheckOut, @UserID, @StatusCode, 0)

					INSERT INTO [reservation].[ReservationStatusLog]
					([ReservationID],[ReservationStatusID],[UserID],[DateTime])
					VALUES(@ReservationID, 4, @UserID, @ActualCheckOut)

					DECLARE @temp table (WalletID int, ReservedRoomRateID int , RowNo int) 

					INSERT INTO @temp
					(WalletID, ReservedRoomRateID, RowNo)
					SELECT t.WalletID, t.ReservedRoomRateID, t.RowNo
					FROM
					(
						SELECT [WalletID]
						,ReservedRoomRateID
						,[DateID]
						,ROW_NUMBER() OVER (ORDER BY [DateID] DESC) RowNo
						FROM [guest].[GuestWallet]
						WHERE ReservationID = @ReservationID AND AccountTypeID = 82 AND IsVoid = 0
					)as t
					WHERE t.RowNo <= @VoidDays

					WHILE(@Init <= @VoidDays)
					BEGIN
						SELECT @ReservedRoomRateID = ReservedRoomRateID, @WalletID = WalletID
						FROM @temp 
						WHERE RowNo = @Init

						UPDATE guest.GuestWallet
						SET IsVoid = 1						
						WHERE ReservedRoomRateID = @ReservedRoomRateID

						UPDATE reservation.RoomRate
						SET IsVoid = 1
						,IsActive = 0
						WHERE ReservedRoomRateID = @ReservedRoomRateID

						SET @Comment = 'Early checkout auto void, ReservationID -> '+ CAST(@ReservationID as varchar(10)) + ' WalletID-> ' + CAST(@WalletID as varchar(10))
						+ ' UserID-> ' + CAST(@UserID as varchar(10)) + ' ReservedRoomRateID -> ' + CAST(@ReservedRoomRateID as varchar(12));

						EXEC [app].[spInsertIntoAudit] @Comment

						SET @Init += 1;
					END

					SET @IsSuccess = 1; --Success

					IF(LEN(@VoucherNumber) > 5)
						BEGIN
							SET @Message = 'Early check-out has been done successfully for Reservation ID : <b>#' + CAST(@ReservationID as varchar(8)) 
							+ '</b>. <br> A voucher number <b>' + @VoucherNumber + '</b> has been generated for the guest.';	
						END
					ELSE
						BEGIN
							SET @Message = 'Early check-out has been done successfully for Reservation ID : <b>#' + CAST(@ReservationID as varchar(8)) + '</b>';
						END

					DECLARE @Folio varchar(50); 
					DECLARE @Guest varchar(200);

					SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
					FROM reservation.Reservation r
					INNER JOIN general.Location l ON r.LocationID = l.LocationID
					INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
					INNER JOIN contact.Details d ON g.ContactID = d.ContactID
					WHERE r.ReservationID = @ReservationID

					DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
					DECLARE @Title varchar(200) = 'Early Check Out: ' + @Guest + '(' + @Folio + ')' + ' has Checked-Out'
					DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
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

					IF(LEN(@VoucherNumber) > 5)
						BEGIN
							SET @Message = 'Early check-out has been done successfully for Reservation ID : ' + CAST(@ReservationID as varchar(8)) 
							+ '. A voucher number ' + @VoucherNumber + ' has been generated for the guest.';	
						END
					ELSE
						BEGIN
							SET @Message = 'Early check-out has been done successfully for Reservation ID : ' + CAST(@ReservationID as varchar(8));
						END
				END;  
		
				---------------------------- Insert into activity log---------------	
				DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
			END CATCH; 		
		END
	ELSE
	BEGIN
		SET @IsSuccess = 0;
		SET @StatusCode = -1;
		SET @Message = 'Someone has change the status of Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' Please refresh the page.';
	END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @VoucherNumber AS [VoucherNumber]
END


