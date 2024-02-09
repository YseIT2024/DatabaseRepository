
CREATE PROCEDURE [reservation].[spMoveInHouse] --10,25,849,'2023-12-30 14:00:00.000','2024-01-02 11:55:00.000',0.00,'2023-12-30 11:55:00.000','change Room',1,1,76,0
(
	@NewRoomID INT,	
	@OldRoomID INT,
	@ReservationID INT,
	@CheckInDate DATE,
	@CheckOutDate DATE,	
	@RoomChangeAmount DECIMAL(18,3),
	@RoomChangeDate DATE,	
	@Reason VARCHAR(MAX),
	@LocationID INT,
	@DrawerID INT,
	@UserID INT,	
	--@dtRate as reservation.dtRoomRate READONLY,
	@isWriteOffTransaction BIT,
	@ItemId int =0

	
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON; 
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @ReservedRoomID int;	
	DECLARE @CheckOutDateId int = (SELECT CAST(FORMAT(@CheckOutDate,'yyyyMMdd') as int));
	DECLARE @RoomChangeDateID int = (SELECT CAST(FORMAT(@RoomChangeDate,'yyyyMMdd') as int));
	DECLARE @OldRoom int;
	DECLARE @NewRoom int;
	DECLARE @RateCurrencyID int;
	DECLARE @ReservationStatusID int;
	DECLARE @ReservationTypeID int;
	DECLARE @GuestID int;
	DECLARE @dtRoom as [reservation].[dtRoom];
	DECLARE @AccountingDateID int;
	DECLARE @Drawer varchar(20);
	DECLARE @Title varchar(200);
	DECLARE @NotDesc varchar(max);

	SELECT @ReservationStatusID = ReservationStatusID, @ReservationTypeID = ReservationTypeID, @GuestID = GuestID
	FROM reservation.Reservation
	WHERE ReservationID = @ReservationID	

	INSERT INTO @dtRoom (RoomID)
	VALUES(@NewRoomID);	
	

	--IF (@ReservationStatusID <> 1 OR @ReservationStatusID <> 3) --Status IN House
	--	BEGIN
	--		SET @IsSuccess = 0; 
	--		SET @Message = 'Reservation status has been changed from outside! Please refresh the page and try again!';
	--	END
	--ELSE IF EXISTS(SELECT tRooms.RoomID FROM (SELECT * FROM [room].[fnCheckIfRoomAvailable](@RoomChangeDateID,@CheckOutDateId,@dtRoom)) tRooms WHERE tRooms.RoomID = @NewRoomID AND tRooms.ReservationID <> @ReservationID)
	--	BEGIN
		
	--		SET @IsSuccess = 0;
	--		SET @Message = 'Selected room is not available! Please refresh the page and try again!';
	--		--insert into TestTable(columnName)values ('A')
	--	END
	--CREATE TABLE TestTable (ColumnName VARCHAR(255))
	--DELETE FROM TestTable;
	
	 IF(@NewRoomID = (SELECT [RoomID] FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID AND RoomID=@OldRoomID AND  IsActive = 1))
		BEGIN
	
			DECLARE @RoomNo varchar(10) = 
			(
				SELECT CAST
				((
				--SELECT Room FROM [reservation].[ReservedRoom]  where RoomID=@OldRoomID aND ReservationID = @ReservationID
					SELECT  r.RoomNo FROM [reservation].[ReservedRoom] rr 
					INNER JOIN Products.Room r ON rr.RoomID = r.RoomID
					WHERE ReservationID = @ReservationID AND rr.IsActive = 1 AND rr.RoomID=@OldRoomID
				) as varchar(10))
			);
			SET @IsSuccess = 0; 
			SET @Message = 'The reservation has already been shifted to Room no <b>' + @RoomNo + '</b>! Please refresh the page.';
		END
	ELSE
		BEGIN TRY
			BEGIN TRANSACTION	
			
				SELECT @OldRoom = RoomNo, @RateCurrencyID = RateCurrencyID, @ReservedRoomID = ReservedRoomID
				FROM [reservation].[ReservedRoom] rm 
				INNER JOIN Products.Room r ON rm.RoomID = r.RoomID 
				WHERE rm.ReservationID = @ReservationID AND rm.roomid= @OldRoomID AND rm.IsActive = 1

				SET @NewRoom = (SELECT RoomNo FROM Products.Room WHERE RoomID = @NewRoomID);
				DECLARE @DiscountId INT= (SELECT TOP 1 DiscountID FROM [reservation].[RoomRate] WHERE ReservedRoomID = @ReservedRoomID);

				

				if (@ReservationStatusID=3)  -- Status change is required only if inhouse Added by Arabinda on 14-12-2023
					begin 

						--DELETE FROM [reservation].[RoomRate] 
						--WHERE ReservedRoomID = @ReservedRoomID AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');

						--DELETE FROM guest.GuestWallet
						--WHERE ReservationID = @ReservationID AND AccountTypeID = 82 AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');

						UPDATE [reservation].[ReservedRoom]
						SET IsActive = 0	
						,UserID = @UserID
						,ModifiedDate = GETDATE()
						WHERE ReservedRoomID = @ReservedRoomID AND IsActive = 1

						UPDATE [Products].[Room] set RoomStatusID=3 where RoomID=@OldRoomID
						UPDATE [Products].[Room] set RoomStatusID=5 where RoomID=@NewRoomID

						UPDATE [Products].[RoomLogs] --[room].[RoomStatusHistory]
						SET ToDate = @RoomChangeDate
						,ToDateID = @RoomChangeDateID
						,RoomStatusID =3
						,IsPrimaryStatus = 0				
						,CreatedBy = @UserID
						WHERE [ReservationID] = @ReservationID AND RoomID = @OldRoomID AND IsPrimaryStatus = 1	

						INSERT INTO [reservation].[ReservedRoomLog]
						([ReservationID],[RoomID],[Date],[UserID])
						VALUES(@ReservationID, @NewRoomID, GETDATE(), @UserID)

						INSERT INTO [Products].[RoomLogs]--[room].[RoomStatusHistory]
						([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[ReservationID],[CreatedBy])	
						VALUES(@NewRoomID, FORMAT(@RoomChangeDate, 'yyyyMMdd'), @CheckOutDateId, 5, 1, @RoomChangeDate, @CheckOutDate, @ReservationID, @UserID)			

						INSERT INTO [reservation].[ReservedRoom]
						([ReservationID],[RoomID],[StandardCheckInOutTimeID],[IsActive],[RateCurrencyID], [ModifiedDate], [UserID],ShiftedRoomID)
						VALUES(@ReservationID, @NewRoomID, 1, 1, 1, GETDATE(), @UserID,@OldRoomID)	
				
						SET @ReservedRoomID = SCOPE_IDENTITY();

						SET @AccountingDateID = (SELECT MAX(AccountingDateId) FROM account.AccountingDates WHERE DrawerID = @DrawerID)


						if(@ItemId>0)
						Begin
							Update RD Set ItemID=@ItemId
							From reservation.ReservationDetails RD where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate)
						End


						--IF(@ReservationTypeID = 7)	--HOUSE USE			
						--	BEGIN
						--		INSERT INTO [reservation].[RoomRate]
						--		([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
						--		SELECT @ReservedRoomID, r.DateID, 230, 0, 1
						--		FROM @dtRate r		
						--	END
						--ELSE
							--BEGIN
							--	INSERT INTO [reservation].[RoomRate]
							--	([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
							--	SELECT @ReservedRoomID, r.DateID, r.RateID, r.Amount, @DiscountId
							--	FROM @dtRate r		
							--END	

						--commented by Arabinda on 14-12-2023 as no use of wallet
						--INSERT INTO [guest].[GuestWallet]
						--([GuestID],[TransactionTypeID],[AccountTypeID],[ReservationID],[ReservedRoomRateID],[DateID],[Amount],[RateCurrencyID],[AccountingDateID],[TransactionDateTime],[Remarks])				
						--SELECT @GuestID, 1, 82, @ReservationID, rt.ReservedRoomRateID, rt.[DateID], (-1)*rt.Rate, @RateCurrencyID, @AccountingDateID, GETDATE(), 'Daily room charge.'
						--FROM Reservation.RoomRate rt 					
						--WHERE rt.ReservedRoomID = @ReservedRoomID
						----------------End---------------------------------

						INSERT INTO [reservation].[ReservationStatusLog]
						([ReservationID],[ReservationStatusID],[Remarks],[UserID],[DateTime])
						VALUES(@ReservationID, 7, @Reason + ', Moved reservation id- ' + CONVERT(VARCHAR, @ReservationID) +', From Room No- ' 
						+ CONVERT(VARCHAR, @OldRoom) + ' to Room No- ' + CONVERT(VARCHAR, @NewRoom) +'.', @UserID, GETDATE())		
								

					end
				Else
					begin

						DELETE FROM [reservation].[RoomRate] 
						WHERE ReservedRoomID = @ReservedRoomID AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');

						DELETE FROM guest.GuestWallet
						WHERE ReservationID = @ReservationID AND AccountTypeID = 82 AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');
												

						UPDATE [reservation].[ReservedRoom]
						SET 
						RoomID=@NewRoomID						
						,UserID = @UserID
						,ModifiedDate = GETDATE()
						WHERE ReservationID=@ReservationID and  RoomID = @OldRoomID						
						
						UPDATE [Products].[RoomLogs] --[room].[RoomStatusHistory]
						SET RoomID=@NewRoomID
						,CreatedBy = @UserID
						,CreateDate=GETDATE()
						WHERE [ReservationID] = @ReservationID AND RoomID = @OldRoomID --AND IsPrimaryStatus = 1


						Update [reservation].[ReservedRoomLog] set
						roomid=@NewRoomID,
						Date=GETDATE()
						where ReservationID=@ReservationID and RoomID=@OldRoomID		
						
						if(@ItemId>0)
						Begin
							Update RD Set ItemID=@ItemId
							From reservation.ReservationDetails RD where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate)
						End
						
					end		
				

						
				SET @IsSuccess = 1; --success
				SET @Message = 'The reservation has been moved to different room successfully.';
				

				DECLARE @Folio varchar(50); 
				DECLARE @Guest varchar(200);

				SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
				FROM reservation.Reservation r
				INNER JOIN general.Location l ON r.LocationID = l.LocationID
				INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
				INNER JOIN contact.Details d ON g.ContactID = d.ContactID
				WHERE r.ReservationID = @ReservationID

				DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
				
				SET  @Title  = 'Reservation has been moved for reservationID- '+ Cast(@ReservationID AS Varchar(20)) + ' '+Cast(@Guest AS Varchar(20)) + ', Folio Number- (' + Cast(@Folio AS Varchar(20)) + ')' + ' from ' + CAST(@OldRoom as varchar) + ' to ' + CAST(@NewRoom as varchar) + ' Room No'
				SET  @NotDesc = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), ' dd-MMM-yyyy HH:mm ') + ' . By User ID: ' + CAST(@UserID as varchar(10));
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
			COMMIT TRANSACTION

			EXEC [app].[spInsertActivityLog] 33,@LocationID,@NotDesc,@UserID,@Message	   ---Added By Somnath
		END TRY  
		BEGIN CATCH    
			IF (XACT_STATE() = -1) 
			BEGIN  			
				ROLLBACK TRANSACTION;  

				SET @Message = ERROR_MESSAGE();
				SET @IsSuccess = 0; --error
				SET @ReservationID = -1; --error
			END;    
    
			IF (XACT_STATE() = 1)  
			BEGIN  			
				COMMIT TRANSACTION;   

				SET @IsSuccess = 1; --success  
				SET @Message = 'The reservation has been moved to different room successfully.';
			END;  
		
			---------------------------- Insert into activity log---------------	
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
			EXEC [app].[spInsertActivityLog] 33,@LocationID,@Act,@UserID	
		END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]	
END

--Select * from [Products].[RoomLogs] where ReservationID=6672

--select * from reservation.ReservationDetails where ReservationID=846
--select * from [Products].[Item] where SubCategoryID=45 and IsActive=1
--select * from Products.SubCategory where CategoryID=1 and IsActive=1
--update reservation.ReservationDetails set ItemID=24 where reservationid=846

--select SC.Name, IT.ItemName, RD.NightDate,RD.Rooms, RD.LineTotal,RD.TotalTaxAmount,SC.SubCategoryID 
--from [reservation].[ReservationDetails] RD
--		INNER JOIN [Products].[Item] IT ON RD.ItemID = IT.ItemID
--		INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID
--		where rd.ReservationID=846
