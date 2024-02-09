CREATE PROCEDURE [reservation].[spCheckedOutToInHouse] --5137,85,1
(	
	@ReservationID int,
	@UserID int,
	@DrawerID int
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
	DECLARE @RSHistoryID int;
	Declare @LocationID int = (SELECT top 1  LocationID FROM reservation.Reservation WHERE ReservationID = @ReservationID)

	IF((SELECT top 1 ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID) = 4) --In House
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
					SET @Message = 'Check Out has been successfully Reversed for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.' ;

					DECLARE @Folio varchar(50); 
					DECLARE @Guest varchar(200);
					 
					SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
					 FROM reservation.Reservation r
					INNER JOIN general.Location l ON r.LocationID = l.LocationID
					INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
					INNER JOIN contact.Details d ON g.ContactID = d.ContactID
					WHERE r.ReservationID = 5124

					DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
					DECLARE @Title varchar(200) = 'Check Out Reversal for ReservationID: ' + CAST(@ReservationID as varchar(12)) + '. ' + @Guest + ', And Folio No(' + @Folio + ')' + ' has been completed successfully.'
					DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
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
					SET @Message = 'Check Out has been successfully Reversed for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.';
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
		SET @Message = 'Someone has change the status of Reservation ID: <b>#' + CAST(@ReservationID as varchar(12))  + '</b>, <br>Please refresh the page.';
	END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @StatusCode AS [StatusCode]
END