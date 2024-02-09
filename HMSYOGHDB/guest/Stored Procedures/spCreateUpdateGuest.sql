

CREATE PROCEDURE [guest].[spCreateUpdateGuest] 
(
	@ReservationTypeID int,
	@GuestID int,
	@ContactID int,
	@AddressID int,
	@LocationID int,
	@UserID int,
	@TitleID int, 
	@FirstName varchar(100),
	@LastName varchar(100) = NULL,	
	@DOB date = NULL,		
	@MaritalStatusID int = NULL,
	@LanguageID int = NULL,	
	@FoodTypeID int = NULL,	
	@OccupationID int = NULL,
	@IDCardTypeID int = NULL,
	@IDCardNumber varchar(30) = NULL,	
	@Reference varchar(50) = NULL,
	@GroupCode varchar(50) = NULL,
	@AddressTypeID int,	
	@Street varchar(50) = NULL,
	@City varchar(30) = NULL,
	@State varchar(30) = NULL,
	@ZipCode varchar(10) = NULL,
	@CountryID int,	
	@PhoneNumber varchar(15) = '',
	@Email varchar(50) = NULL,
	@ReservationID int = 0,
	@CustomerLogo varchar(150)=NULL,
	@CustomerNo varchar(50),
	@Base64Image nvarchar(max)
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @GenderID int;
	DECLARE @Title varchar(200);
	DECLARE @NotDesc varchar(max);
	DECLARE @Location varchar(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
	DECLARE @ImageID int;

	BEGIN TRY			
		IF(@IDCardTypeID <= 0)
		SET @IDCardTypeID = NULL;

		IF(@MaritalStatusID <= 0)
		SET @MaritalStatusID = NULL;

		IF(@LanguageID <= 0)
		SET @LanguageID = NULL;

		IF(@FoodTypeID <= 0)
		SET @FoodTypeID = NULL;

		IF(@OccupationID <= 0)
		SET @OccupationID = NULL;

		SELECT @GenderID = GenderID
		FROM person.Title
		WHERE TitleID = @TitleID
	
		BEGIN TRANSACTION	
			IF(@GuestID = 0)
				BEGIN		
					if(@Base64Image is not null or @Base64Image <>'')
						begin
						INSERT INTO general.Image(GuestImage) 
						VALUES(@Base64Image)
						SET @ImageID = SCOPE_IDENTITY();
					end

					INSERT INTO [contact].[Details]
					([TitleID],[FirstName],[LastName],[DOB],[MaritalStatusID],[LanguageID],[OccupationID],[IDCardTypeID],[IDCardNumber],[GenderID],ImageID)
					VALUES(@TitleID,@FirstName,@LastName,@DOB,@MaritalStatusID,@LanguageID,@OccupationID,@IDCardTypeID,@IDCardNumber,@GenderID,@ImageID)

					SET @ContactID = SCOPE_IDENTITY();

					INSERT INTO [contact].[Address]
					([ContactID],[AddressTypeID],[Street],[City],[State],[ZipCode],[CountryID],[Email],[PhoneNumber],[IsDefault])
					VALUES(@ContactID,@AddressTypeID,@Street,@City,@State,@ZipCode,@CountryID,@Email,@PhoneNumber,1)

					Declare @CustomerPrefix varchar(20);
					select @CustomerPrefix= isnull([value],'CUS') from app.Parameter where ParameterID =1

					select @CustomerNo= @CustomerPrefix+convert(varchar, isnull(max(CustomerID),0)+ 1001)  
					from general.Customer

					insert into general.Customer(ContactID,CustomerNo,IsFromCP,CreatedBy,CreatedDate, ReservationTypeID)
					values(@ContactID,@CustomerNo,0,@UserID,GETDATE(),@ReservationTypeID)

					--INSERT INTO [guest].[Guest]
					--(ContactID,Reference,GroupCode,FoodTypeID)
					--VALUES(@ContactID,@Reference,@GroupCode,@FoodTypeID)

					--Added by Arabinda on 28/04/2023
					INSERT INTO [guest].[Guest]
							([ContactID])
							VALUES(@ContactID)
					-------------End----------------------

					SET @GuestID = SCOPE_IDENTITY();

					SET @Message = 'New guest has been added successfully.';
					SET @IsSuccess = 1; --success

					SET @Title = 'Guest: ' + @FirstName + ' ' + ISNULL(@LastName,'') + ' has added'
					SET @NotDesc = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc						
			    END
			ELSE
				BEGIN		
				
					if(@Base64Image is not null or @Base64Image <>'')
					begin
					INSERT INTO general.Image(GuestImage) 
					VALUES(@Base64Image)
					SET @ImageID = SCOPE_IDENTITY();
					end

					UPDATE [contact].[Details]
					SET [TitleID] = @TitleID
					,[FirstName] = @FirstName
					,[LastName] = @LastName
					,[DOB] = @DOB
					,[MaritalStatusID] = @MaritalStatusID
					,[LanguageID] = @LanguageID
					,[OccupationID] = @OccupationID
					,[IDCardTypeID] = @IDCardTypeID
					,[IDCardNumber] = @IDCardNumber
					,[GenderID] = @GenderID
					,ImageID=@ImageID
					WHERE ContactID = @ContactID

					UPDATE [contact].[Address]
					SET [AddressTypeID] = @AddressTypeID
					,[Street] = @Street
					,[City] = @City
					,[State] = @State
					,[ZipCode] = @ZipCode
					,[CountryID] = @CountryID
					,[Email] = @Email
					,[PhoneNumber] = @PhoneNumber
					,[IsDefault] = 1
					WHERE AddressID = @AddressID  					

					UPDATE general.Customer
					SET [ReservationTypeID] = @ReservationTypeID
					WHERE [CustomerNo] = @CustomerNo	

					--UPDATE general.Customer
					--SET [Reference] = @Reference
					--,[GroupCode] = @GroupCode
					--,[FoodTypeID] = @FoodTypeID
					--WHERE GuestID = @GuestID					

					SET @Message = 'Guest has been updated successfully.';
					SET @IsSuccess = 1; --success

					SET @Title = 'Guest: ' + @FirstName + ' ' + ISNULL(@LastName,'') + ' has updated'
					SET @NotDesc = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc					
				END	
		
			IF(@ReservationID > 0)
			BEGIN
				UPDATE reservation.Reservation
				SET GuestID = @GuestID
				WHERE ReservationID = @ReservationID

				DECLARE @Folio varchar(50) = (SELECT CONCAT(@Location,FolioNumber) FROM reservation.Reservation WHERE ReservationID = @ReservationID)

				SET @Title = 'Reservation: ' + 'Folio number ' + @Folio  + ' reservation guest has updated to ' + @FirstName + ' ' + ISNULL(@LastName,'')
				SET @NotDesc = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
			END			
		COMMIT TRANSACTION	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  

			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --success 

			IF(@ContactID = 0)
				BEGIN 
					SET @Message = 'New guest has been added successfully.';
				END
			ELSE
				BEGIN
					SET @Message = 'Guest has been updated successfully.';
				END
		END;  
		
		--------------Insert into activity log----------------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END
