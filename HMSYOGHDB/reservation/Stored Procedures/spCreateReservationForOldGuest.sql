
CREATE Proc [reservation].[spCreateReservationForOldGuest]
(
	@GuestID int,	
	@PhoneNumber varchar(15),
	@ReservationTypeID int,
	@ReservationModeID int,
	@ExpectedCheckIn datetime,
	@ExpectedCheckOut datetime,	
	@Adults int,
	@ExtraAdults int,
	@Children int,
	@Rooms int,
	@Nights int,	
	@Hold_TransactionModeID int,		
	@LocationID int,
	@UserID int,	
	@GroupCode varchar(20) = NULL,		
	@StaffNote varchar(max) = NULL,
	@GuestNote varchar(max) = NULL,
	@Remarks varchar(max) = NULL,	
	@DiscountPercentage int,
	@CompanyID int,
	@dtRoom as [reservation].[dtRoom] readonly,
	@dtRate as [reservation].[dtRoomRate] readonly
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
	DECLARE @ReservationID int = 0;	
	DECLARE @DiscountID int = NULL;
	DECLARE @ReservedRoomID int;
	DECLARE @RoomID int;
	DECLARE @Init int = 1;
	DECLARE @ExtraChildren int;
	DECLARE @FolioNumbers VARCHAR(100) = '';
	DECLARE @CurrencyID int;
	DECLARE @FolioNumber int;	

	BEGIN TRY

		DECLARE @LocationCode VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
		DECLARE @CheckInDateId int = (SELECT CAST(FORMAT(@ExpectedCheckIn,'yyyyMMdd') as int));
		DECLARE @CheckOutDateId int = (SELECT CAST(FORMAT(@ExpectedCheckOut,'yyyyMMdd') as int));
		DECLARE @NumberOfFreeChild int = (SELECT Value FROM app.Parameter WHERE ParameterID = 1);
		 
		SET @ExpectedCheckIn = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckIn,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckInTime]()))));
		SET @ExpectedCheckOut = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckOut,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckOutTime]()))));
		SET @Nights = DATEDIFF(DAY,@ExpectedCheckIn,@ExpectedCheckOut);

		IF NOT EXISTS (SELECT * FROM [room].[fnCheckIfRoomAvailable] (@CheckInDateId, @CheckOutDateId, @dtRoom))--If rooms are available
			BEGIN
				BEGIN TRANSACTION						
					SET @ContactID = (SELECT ContactID FROM guest.Guest WHERE GuestID = @GuestID);
					SET @AddressID = (SELECT AddressID FROM contact.Address WHERE ContactID = @ContactID AND IsDefault = 1);
										
					IF @PhoneNumber != ''
					BEGIN
						UPDATE [contact].[Address]
						SET [PhoneNumber] = @PhoneNumber					
						WHERE AddressID = @AddressID
					END				

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
					
					WHILE(@Init <= @Rooms)
					BEGIN
						SELECT 
						@Adults = t.Adults
						,@Children = t.Children
						,@ExtraAdults = t.ExtraAdults
						,@ExtraChildren = t.Children
						,@RoomID = t.RoomID
						FROM @dtRoom t 
						WHERE t.ID = @Init

						SELECT @CurrencyID = p.CurrencyID
						FROM room.Rate rat
						INNER JOIN currency.Price p ON rat.Adult1PriceID = p.PriceID
						WHERE rat.RateID = 
						(
							SELECT TOP 1 r.RateID
							FROM @dtRate r
							WHERE r.RoomID = @RoomID
						);

						IF(@ExtraChildren > @NumberOfFreeChild)
							SET @ExtraChildren = @ExtraChildren - @NumberOfFreeChild;
						ELSE
							SET @ExtraChildren = 0;
								
						SET @FolioNumber = (SELECT [reservation].[fnGenerateFolioNumber](@LocationID));

						INSERT INTO [reservation].[Reservation]
						([ReservationTypeID],[ReservationModeID],[ExpectedCheckIn],[ExpectedCheckOut],[GuestID],[Adults],[ExtraAdults],[Children],[Rooms],[Nights],
						[ReservationStatusID],[Hold_TransactionModeID],[UserID],[DateTime],[LocationID],[FolioNumber],[CompanyID])
						VALUES(@ReservationTypeID,@ReservationModeID,@ExpectedCheckIn,@ExpectedCheckOut,@GuestID,@Adults,@ExtraAdults,@Children,1,@Nights,
						1,@Hold_TransactionModeID,@UserID,GETDATE(),@LocationID,@FolioNumber,@CompanyID)

						SET @ReservationID = SCOPE_IDENTITY();	

						INSERT INTO [room].[RoomStatusHistory]
						([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[ReservationID],[UserID])	
						SELECT t.RoomID, @CheckInDateId,@CheckOutDateId,2,1,@ExpectedCheckIn,@ExpectedCheckOut,@ReservationID,@UserID
						FROM @dtRoom t			
						WHERE t.RoomID = @RoomID
						
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
							INSERT INTO [reservation].[Note]
							([NoteTypeID],[ReservationID],[Note],[UserID],[DateTime])
							VALUES(1,@ReservationID,@StaffNote,@UserID,GETDATE())
						END

						IF(@GuestNote IS NOT NULL)
						BEGIN
							INSERT INTO [reservation].[Note]
							([NoteTypeID],[ReservationID],[Note],[UserID],[DateTime])
							VALUES(3,@ReservationID,@GuestNote,@UserID,GETDATE())
						END

						IF(@Remarks IS NOT NULL)
						BEGIN
							INSERT INTO [reservation].[Note]
							([NoteTypeID],[ReservationID],[Note],[UserID],[DateTime])
							VALUES(4,@ReservationID,@Remarks,@UserID,GETDATE())
						END

						INSERT INTO [reservation].[ReservationStatusLog]
						([ReservationID],[ReservationStatusID],[UserID],[DateTime], [Remarks])
						VALUES(@ReservationID, 1, @UserID, GETDATE(), 'New reservation has been created. @ExpectedCheckIn -> ' + FORMAT(@ExpectedCheckIn,'dd-MMM-yyyy') + ' @ExpectedCheckOut -> ' + FORMAT(@ExpectedCheckOut,'dd-MMM-yyyy'))

						INSERT INTO [reservation].[ReservedRoomLog]
						([ReservationID],[RoomID],[Date],[UserID])
						VALUES(@ReservationID, @RoomID, GETDATE(), @UserID)

						SET @FolioNumbers = @FolioNumbers + ' ' + '<b>' + @LocationCode + CONVERT(VARCHAR,@FolioNumber) + '</b>' + ','
						SET @Init += 1;
					END
					
					SET @FolioNumbers = LEFT(@FolioNumbers, LEN(@FolioNumbers)-1)
					SET @Message = (SELECT [guest].[fnGetGuestFullName](@GuestID));

					SET @IsSuccess = 1; --success
					SET @Message = 'New reservation has been created successfully for <b>' + @Message + '</b>';		
					
							DECLARE @Title varchar(200) = 'Reservation: ' + (SELECT FirstName + ' ' + ISNULL(LastName, '') FROM guest.Guest g
							INNER JOIN contact.Details d ON g.ContactID = d.ContactID
							WHERE GuestID = @GuestID) + '(' +
							+ CONCAT(@LocationCode,@FolioNumber) + ') reservation has created'
							
							DECLARE @NotDesc varchar(max) = @Title + ' at ' + @LocationCode + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
							EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc			
				COMMIT TRANSACTION
			END
		ELSE
			BEGIN
				SET @IsSuccess = 0; 
				SET @FolioNumbers = -2; --Insufficient vacant room
				SET @Message = 'Insufficient vacant room for reservation.';
			END
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			SET @FolioNumbers = -1; --error
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --success  
			SET @Message = 'New reservation has been created successfully for ' + @Message;
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumbers AS [FolioNumber]
END




