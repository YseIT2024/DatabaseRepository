
CREATE PROCEDURE [BQTReservation].[usp_BQTBooking_IU] 
	@BookingID INT=null,
	@LocationID INT=1,
	@BookingModeID INT,
	@FolioNumber INT =0,	
	@CompanyID INT=0,
	@EventStartDate DATETIME,
	@EventEndDate DATETIME,
	@EventStartTime DATETIME,
	@EventEndTime DATETIME,
	@BQTRooms VARCHAR(100),
	@MenuPlan VARCHAR(100),
	@Setup VARCHAR(100),
	@Notes VARCHAR(250),
	@TypeOfEvent INT,
	@EventNameId INT,
	@RoomRequired INT=0,
	@MediaRequired BIT= 1,
	@TotalPax INT=1,
	@BookingStatusId INT,
	@TotalAmountBeforeTax DECIMAL(18, 4)= 0,
	@TotalTaxAmount DECIMAL(18, 4)= 0,
	@TotalAmountAfterTax DECIMAL(18, 4),
	@TaxId INT =3,
	@TaxPercent INT=10,
	@AdditionalDiscountAmount DECIMAL(18, 4)=0,
	@TotalPayable DECIMAL(18, 4)=0,
	@AdvancePaid DECIMAL(18, 4),
	@CurrencyID INT=1,
	@RequiredAMTtoConfirm DECIMAL(18, 4)=0,
	@SalesManagerId INT=0,
	@UserId INT,
	@ContactId int=null,
	@AddressId int=null,
	@TitleID int, 
	@FirstName varchar(100),
	@LastName varchar(100),
	@DOB Datetime,
	@AddressTypeID int,
	@Street varchar(50),
	@City varchar(30),
	@State varchar(30),
	@ZipCode varchar(10),
	@CountryID int,
	@Email varchar(50),
	@PhoneNumber varchar(15)
	--@GenderID
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @IsSuccess BIT = 0;
	DECLARE @Message VARCHAR(MAX) = '';
	DECLARE @GenderID int;
	--Declare @AddressId int;
	--Declare @ContactId int;
	SELECT @GenderID = GenderID
		FROM person.Title
		WHERE TitleID = @TitleID
   

	BEGIN TRY
		BEGIN TRANSACTION
		
		IF EXISTS (SELECT * FROM [BQTReservation].[BQTBooking] WHERE BookingID = @BookingID)
		
		BEGIN 


		IF EXISTS (SELECT * FROM [contact].[Details] WHERE ContactID = @ContactID)
           BEGIN
    -- Update the contact details
              UPDATE [contact].[Details]
               SET [TitleID] = @TitleID,
             [FirstName] = @FirstName,
             [LastName] = @LastName,
             [DOB] = @DOB,
            [GenderID] = @GenderID
            WHERE ContactID = @ContactID
             END

          IF EXISTS (SELECT * FROM [contact].[Address] WHERE AddressID = @AddressId)
       BEGIN
    -- Update the address details
        UPDATE [contact].[Address]
		   SET [AddressTypeID] = @AddressTypeID,
			[Street] = @Street,
			[City] = @City,
			[State] = @State,
			[ZipCode] = @ZipCode,
			[CountryID] = @CountryID,
			[Email] = @Email,
			[PhoneNumber] = @PhoneNumber
        WHERE AddressID =@AddressId
        END
	  

	    UPDATE [BQTReservation].[BQTBooking]
			SET LocationID = @LocationID,
				BookingModeID = @BookingModeID,
				FolioNumber = @FolioNumber,
				ContactID=@ContactId,
				CompanyID = @CompanyID,
				EventStartDate = @EventStartDate,
				EventEndDate = @EventEndDate,
				EventStartTime = @EventStartTime,
				EventEndTime = @EventEndTime,
				BQTRooms = @BQTRooms,
				MenuPlan = @MenuPlan,
				Setup = @Setup,
				Notes = @Notes,
				EventTypeId = @TypeOfEvent,
				EventNameId=@EventNameId,
				RoomRequired = @RoomRequired,
				MediaRequired = @MediaRequired,
				TotalPax = @TotalPax,
				BookingStatusId = @BookingStatusId,
				TotalAmountBeforeTax = @TotalAmountBeforeTax,
				TotalTaxAmount = @TotalTaxAmount,
				TotalAmountAfterTax = @TotalAmountAfterTax,
				TaxId = @TaxId,
				TaxPercent = @TaxPercent,
				AdditionalDiscountAmount = @AdditionalDiscountAmount,
				TotalPayable = @TotalPayable,
				AdvancePaid = @AdvancePaid,
				CurrencyID = @CurrencyID,
				ModifiedDate =GETDATE(),
				ModifiedBy = @UserId,
				RequiredAMTtoConfirm = @RequiredAMTtoConfirm,
				SalesManagerId = @SalesManagerId
			WHERE BookingID = @BookingID

			SET @IsSuccess = 1; -- success
			SET @Message = 'BQT Booking Updated Successfully.';
		END
		ELSE
		BEGIN

		INSERT INTO [contact].[Details]
					([TitleID],[FirstName],[LastName],[DOB],[GenderID])
					VALUES(@TitleID,@FirstName,@LastName,@DOB,@GenderID)
		SET @ContactID = SCOPE_IDENTITY();
		INSERT INTO [contact].[Address]
		([ContactID],[AddressTypeID],[Street],[City],[State],[ZipCode],[CountryID],[Email],[PhoneNumber])
	      VALUES(@ContactID,@AddressTypeID,@Street,@City,@State,@ZipCode,@CountryID,@Email,@PhoneNumber)
			  
			  
	    INSERT INTO [BQTReservation].[BQTBooking]
			(			
				LocationID,
				BookingModeID,
				FolioNumber,	
				ContactId,
				CompanyId,
				EventStartDate,
				EventEndDate,
				EventStartTime,
				EventEndTime,
				BQTRooms,
				MenuPlan,
				Setup,
				Notes,
				EventTypeId,
				EventNameId,
				RoomRequired,
				MediaRequired,
				TotalPax,
				BookingStatusId,
				TotalAmountBeforeTax,
				TotalTaxAmount,
				TotalAmountAfterTax,
				TaxId,
				TaxPercent,
				AdditionalDiscountAmount,
				TotalPayable,
				AdvancePaid,
				CurrencyID,				
				CreatedBy,
				CreatedDate,
				RequiredAMTtoConfirm,
				SalesManagerId
			)
			VALUES
			(
				--@BookingID,
				@LocationID,
				@BookingModeID,
				@FolioNumber,
				--@GuestId,
				@ContactId,
				@CompanyID,
				@EventStartDate,
				@EventEndDate,
				@EventStartTime,
				@EventEndTime,
				@BQTRooms,
				@MenuPlan,
				@Setup,
				@Notes,
				--@TypeOfEvent,
				@TypeOfEvent,
				@EventNameId,
				@RoomRequired,
				@MediaRequired,
				@TotalPax,
				@BookingStatusId,
				@TotalAmountBeforeTax,
				@TotalTaxAmount,
				@TotalAmountAfterTax,
				@TaxId,
				@TaxPercent,
				@AdditionalDiscountAmount,
				@TotalPayable,
				@AdvancePaid,
				@CurrencyID,
				@UserId,
				GETDATE(),
				@RequiredAMTtoConfirm,
				@SalesManagerId
			)
			--SET @BookingID = SCOPE_IDENTITY();
			SET @IsSuccess = 1; -- success
			SET @Message = 'BQT Booking Inserted Successfully.';
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF (XACT_STATE() = -1)
		BEGIN
			ROLLBACK TRANSACTION;
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; -- error
		END;

		-- Log the error in the activity log
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());
		EXEC [app].[spInsertActivityLog] 20, @LocationID, @Act, @UserId
	END CATCH;

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END
