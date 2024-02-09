
CREATE Proc [reservation].[spUpdateReservation]
(
	@ReservationID int,
	@GuestID int,	
	@ExpectedCheckIn datetime,
	@ExpectedCheckOut datetime,	
	@Adults int,
	@ExtraAdults int,
	@Children int,
	@Rooms int,
	@Nights int,		
	@LocationID int,
	@UserID int,
	@StaffNote varchar(max) = NULL,
	@GuestNote varchar(max) = NULL,
	@Remarks varchar(max) = NULL,	
	@DiscountPercentage int,
	@CompanyID int,
	@dtRoom as [reservation].[dtRoom] readonly,
	@dtRate as [reservation].[dtRoomRate] readonly,
	@Hold_TransactionModeID int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON;  

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @ContactID int;	
	DECLARE @AddressID int;
	DECLARE @DiscountID int = NULL;
	DECLARE @ReservedRoomID int;
	DECLARE @RoomID int;
	DECLARE @Init int = 1;
	DECLARE @ExtraChildren int;
	DECLARE @RoomRateID int;
	DECLARE @CurrencyID int;
	DECLARE @FolioNumber VARCHAR(50);
	DECLARE @LocationCode VARCHAR(10);
	DECLARE @ReservationTypeID int;

	BEGIN TRY		
		IF((SELECT ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID) = 1)--//If Status is Reserved 
		BEGIN			
			DECLARE @CheckInDateId int = (SELECT CAST(FORMAT(@ExpectedCheckIn,'yyyyMMdd') as int));
			DECLARE @CheckOutDateId int = (SELECT CAST(FORMAT(@ExpectedCheckOut,'yyyyMMdd') as int));
			DECLARE @NumberOfFreeChild int = (SELECT Value FROM app.Parameter WHERE ParameterID = 1);
		 
			SET @ExpectedCheckIn = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckIn,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckInTime]()))));
			SET @ExpectedCheckOut = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckOut,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckOutTime]()))));
			SET @Nights = DATEDIFF(DAY,@ExpectedCheckIn,@ExpectedCheckOut);

			IF NOT EXISTS(SELECT * FROM [room].[fnCheckIfRoomAvailable] (@CheckInDateId, @CheckOutDateId, @dtRoom) WHERE ReservationID <> @ReservationID)--If rooms are available
				BEGIN
					BEGIN TRANSACTION	
						IF(@Rooms > 1)
							BEGIN
								SET @Message = 'You can not update more than one room at a time';
								SET @IsSuccess = 0; --error
								SET @FolioNumber = -1; --error
							END
						ELSE
							BEGIN
								SELECT @ReservationTypeID = ReservationTypeID
								FROM [reservation].[Reservation] WHERE ReservationID = @ReservationID

								SELECT @DiscountID = d.[DiscountID]
								FROM reservation.Discount d
								WHERE d.[Percentage] = @DiscountPercentage
							
								IF(@DiscountID IS NULL)
								BEGIN
									INSERT INTO [reservation].[Discount]
									([Percentage], [Description])
									VALUES(@DiscountPercentage, CAST(@DiscountPercentage as varchar(5)) + '% DISCOUNT')

									SET @DiscountID = SCOPE_IDENTITY();
								END						
						
								SELECT 
								@Adults = t.Adults
								,@Children = t.Children
								,@ExtraAdults = t.ExtraAdults
								,@ExtraChildren = t.Children
								,@RoomID = t.RoomID
								FROM @dtRoom t 
								WHERE t.ID = @Init

								IF(@ExtraChildren > @NumberOfFreeChild)
									SET @ExtraChildren = @ExtraChildren - @NumberOfFreeChild;
								ELSE
									SET @ExtraChildren = 0;

								UPDATE [reservation].[Reservation] SET
								[ExpectedCheckIn] = @ExpectedCheckIn
								,[ExpectedCheckOut] = @ExpectedCheckOut
								,[Adults] = @Adults
								,[ExtraAdults] = @ExtraAdults
								,[Children] = @Children
								,[Nights] = @Nights
								,[UserID] = @UserID
								,[DateTime] = GETDATE()							
								,GuestID = @GuestID
								,CompanyID = @CompanyID
								,[Hold_TransactionModeID] = @Hold_TransactionModeID
								WHERE ReservationID = @ReservationID		
							
								SET @LocationCode = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
								SET @FolioNumber = (SELECT '<b>' + @LocationCode + CAST(FolioNumber as varchar(10)) + '</b>' FROM [reservation].[Reservation] WHERE ReservationID = @ReservationID)

								UPDATE [room].[RoomStatusHistory] SET
								[RoomID] = @RoomID
								,[FromDateID] = @CheckInDateId
								,[ToDateID] = @CheckOutDateId
								,[FromDate] = @ExpectedCheckIn
								,[ToDate] = @ExpectedCheckOut
								,[UserID] = @UserID
								WHERE [ReservationID] = @ReservationID  AND IsPrimaryStatus = 1							
						
								SET @ReservedRoomID = (SELECT ReservedRoomID FROM [reservation].[ReservedRoom]
								WHERE ReservationID = @ReservationID)
							 
								DELETE FROM [reservation].[RoomRate] 
								WHERE ReservedRoomID = @ReservedRoomID

								DELETE [reservation].[ReservedRoom]
								WHERE ReservedRoomID = @ReservedRoomID								
							
								SELECT @CurrencyID = p.CurrencyID
								FROM room.Rate rat
								INNER JOIN currency.Price p ON rat.Adult1PriceID = p.PriceID
								WHERE rat.RateID = 
								(
									SELECT TOP 1 r.RateID
									FROM @dtRate r
									WHERE r.RoomID = @RoomID
								);							

								INSERT INTO [reservation].[ReservedRoom]
								([ReservationID],[RoomID],[StandardCheckInOutTimeID],[IsActive],[RateCurrencyID])
								SELECT @ReservationID, t.RoomID, 1, 1, @CurrencyID					
								FROM @dtRoom t 
								WHERE t.RoomID = @RoomID

								SET @ReservedRoomID = SCOPE_IDENTITY();
								
								IF(@ReservationTypeID = 7)	--HOUSE USE							
									BEGIN
										INSERT INTO [reservation].[RoomRate]
										([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
										SELECT @ReservedRoomID, r.DateID, 230, 0, 1
										FROM @dtRate r
										WHERE r.RoomID = @RoomID
									END
								ELSE
									BEGIN
										INSERT INTO [reservation].[RoomRate]
										([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
										SELECT @ReservedRoomID, r.DateID, r.RateID, r.Amount, @DiscountID
										FROM @dtRate r
										WHERE r.RoomID = @RoomID
									END

								IF(@StaffNote IS NOT NULL)
								BEGIN
									UPDATE [reservation].[Note] SET
									[Note] = @StaffNote
									,[UserID] = @UserID
									,[DateTime] = GETDATE()
									WHERE ReservationID =  @ReservationID
								END

								IF(@GuestNote IS NOT NULL)
								BEGIN
									UPDATE [reservation].[Note] SET 
									[Note] = @GuestNote
									,[UserID] = @UserID
									,[DateTime] = GETDATE()
									WHERE ReservationID  = @ReservationID							
								END

								IF(@Remarks IS NOT NULL)
								BEGIN
									UPDATE [reservation].[Note] SET
									[Note] = @Remarks
									,[UserID] = @UserID
									,[DateTime] = GETDATE()
									WHERE ReservationID  = @ReservationID
								END		
								
								INSERT INTO [reservation].[ReservedRoomLog]
								([ReservationID],[RoomID],[Date],[UserID])
								VALUES(@ReservationID, @RoomID, GETDATE(), @UserID)

								INSERT INTO [reservation].[ReservationStatusLog]
								([ReservationID], [ReservationStatusID], [Remarks], [UserID], [DateTime])
								VALUES(@ReservationID, 5, 'Reservation details has been updated.', @UserID, GETDATE())

								SET @IsSuccess = 1; --success
								SET @Message = (SELECT [guest].[fnGetGuestFullName](@GuestID));

								SET @Message = 'Reservation has been updated successfully for <b>' + @Message + '</b>';	

								DECLARE @Folio varchar(50); 
								DECLARE @Guest varchar(200);

								SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
								FROM reservation.Reservation r
								INNER JOIN general.Location l ON r.LocationID = l.LocationID
								INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
								INNER JOIN contact.Details d ON g.ContactID = d.ContactID
								WHERE r.ReservationID = @ReservationID

								DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
								DECLARE @Title varchar(200) = 'Reservation: ' + @Guest + '(' + @Folio + ')' + ' reservation has updated'
								
								DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
								EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
							END
					COMMIT TRANSACTION	
				END
			ELSE
				BEGIN
					SET @IsSuccess = 0; 
					SET @FolioNumber = -2; --Insufficient vacant room
					SET @Message = 'Selected room(s) not available for reservation. Please check for status.';
				END
		END	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			SET @FolioNumber = -1; --error
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --success  
			SET @Message = 'Reservation has been updated successfully.';
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH; 	

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumber AS [FolioNumber] 
END

