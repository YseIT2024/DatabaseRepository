
CREATE PROCEDURE [guest].[spAddUpdateGuest]
(
	@GuestID int,
	@FirstName varchar(30),
	@LastName varchar(30) = NULL,
	@CountryID int,
	@TitleID int,
	@PhoneNumber varchar(30),
	@LocationID int,
	@UserID int,
	@ReservationTypeID int=0  --Added by Arabinda on 10-06-2023
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON;  

	DECLARE @GenderID INT;
	DECLARE @ContactID INT;
	DECLARE @AddressTypeID INT = 1;
	DECLARE @AddressID INT;
	DECLARE @IsSuccess BIT = 0;
	DECLARE @Message VARCHAR(MAX);

	BEGIN TRY  
		BEGIN TRANSACTION
			IF(@GuestID > 0) ---Update
				BEGIN
					SET @ContactID = (SELECT ContactID FROM guest.Guest WHERE GuestID = @GuestID);
					SET @AddressID = (SELECT AddressID FROM contact.Address WHERE ContactID = @ContactID AND IsDefault = 1);
					SET @GenderID = (SELECT GenderID FROM person.Title WHERE TitleID = @TitleID);

					IF NOT EXISTS(Select PhoneNumber from [contact].[Address] where PhoneNumber = @PhoneNumber and ContactID != @ContactID AND @PhoneNumber != '')
						BEGIN
							UPDATE [contact].[Details]
							SET [TitleID] = @TitleID
							,[FirstName] = @FirstName
							,[LastName] = @LastName
							,[GenderID] = @GenderID
							WHERE ContactID = @ContactID

							UPDATE [contact].[Address]
							SET [PhoneNumber] = ISNULL(@PhoneNumber,'')	
							,CountryID = @CountryID
							WHERE AddressID = @AddressID

							SET @IsSuccess = 1;
						END
					ELSE
					    BEGIN 
							SET @Message = 'Phone Number already exists. Please Enter another number.';
							SET @IsSuccess = 0; --unsuccess
					    END 
				END
			ELSE --- ADD
				BEGIN
					IF NOT EXISTS(SELECT AddressID FROM contact.Address WHERE PhoneNumber = @PhoneNumber AND @PhoneNumber != '')
						BEGIN
							SET @GenderID = (SELECT GenderID FROM person.Title WHERE TitleID = @TitleID);

							INSERT INTO [contact].[Details]
							([TitleID],[FirstName],[LastName],[GenderID])
							VALUES(@TitleID, @FirstName, @LastName, @GenderID)

							SET @ContactID = SCOPE_IDENTITY();

							INSERT INTO [contact].[Address]
							([AddressTypeID],[ContactID],[CountryID],[PhoneNumber],[IsDefault])
							VALUES(@AddressTypeID, @ContactID, @CountryID, @PhoneNumber, 1)

							INSERT INTO [guest].[Guest]
							([ContactID])
							VALUES(@ContactID)

							------------Added by Arabinda on 10-06-2023 to insert into customer if creating from New reservation screen-------------
							Declare @CustomerPrefix varchar(20);
							select @CustomerPrefix= isnull([value],'CUS') from app.Parameter where ParameterID =1

							Declare @CustomerNo varchar(20);
							select @CustomerNo= @CustomerPrefix+convert(varchar, isnull(max(CustomerID),0)+ 1001)  from general.Customer

							insert into general.Customer(ContactID,CustomerNo,IsFromCP,CreatedBy,CreatedDate, ReservationTypeID)
							values(@ContactID,@CustomerNo,0,@UserID,GETDATE(),@ReservationTypeID)

							-----------------------End-----------------------------------------------------

							SET @IsSuccess = 1;
						END
					ELSE
						BEGIN
							SET @IsSuccess = 0;
							SET @Message = 'Phone number ' + @PhoneNumber + ' already exists for Guest: ' 
							+ (SELECT TOP 1 FirstName + ' ' + ISNULL(cd.LastName,'')
							FROM contact.Details cd
							INNER JOIN contact.Address a ON cd.ContactID = a.ContactID
							WHERE PhoneNumber = @PhoneNumber)
						END
				END
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
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess [IsSuccess], @Message [Message]
END
