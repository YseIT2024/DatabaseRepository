
CREATE PROCEDURE [company].[spSaveCompany]
(
	@CompanyID int,
	@Name varchar(100),
	@Type varchar(100),
	@PhoneNo varchar(100),
	@Address varchar(100),
	@ContactPersonName varchar(100),
	@ContactPersonPhone varchar(100),
	@ContactPersonEmail varchar(100),
	@ContactID int,
	@UserID int,
	@DrawerID int
)
AS
BEGIN
	DECLARE @Success Bit = 0;
	DECLARE @Message varchar(100) = ''
	
	DECLARE @LocationID int;
	DECLARE @Drawer varchar(20);
	DECLARE @Title varchar(200);
	DECLARE @NotDesc varchar(max);

	SELECT @LocationID = LocationID, @Drawer = Drawer FROM app.Drawer WHERE DrawerID = @DrawerID	

	BEGIN TRY

		IF NOT EXISTS(SELECT ContactID FROM contact.Details WHERE ContactID = @ContactID AND FirstName = @ContactPersonName)
			BEGIN
				INSERT INTO contact.Details(FirstName)
				SELECT @ContactPersonName

				SET @ContactID = SCOPE_IDENTITY();
			END

		IF @ContactID != 0
		BEGIN			
			IF NOT EXISTS(SELECT AddressID FROM contact.Address WHERE ContactID = @ContactID AND PhoneNumber = @ContactPersonPhone AND Email = @ContactPersonEmail)
			BEGIN
				INSERT INTO contact.Address(ContactID, CountryID, AddressTypeID, PhoneNumber, Email)
				SELECT @ContactID, 164, 1, @ContactPersonPhone, @ContactPersonEmail
			END
		ELSE
			BEGIN
				UPDATE contact.Address SET
				PhoneNumber = @ContactPersonPhone,
				Email = @ContactPersonEmail
				WHERE ContactID = @ContactID
			END
		END	

		IF @CompanyID = 0
			BEGIN	
				IF NOT EXISTS(SELECT CompanyID FROM company.Company WHERE CompanyName = @Name AND Address = @Address)	
				BEGIN
					INSERT INTO [company].[Company]
					([CompanyName],[CompanyType],[Address],[PhoneNumber],[ContactID])
					VALUES(@Name, @Type, @Address, @PhoneNo, @ContactID)

					SET @CompanyID = SCOPE_IDENTITY();

					INSERT INTO company.CompanyAndContactPerson(CompanyID, ContactID, IsActive)
					SELECT @CompanyID, @ContactID, 1

					SET @Success = 1;
					SET @Message = 'New company has been added successfully.'					
					
					SET @Title = 'Company: ' + @Name + ' has added'
					
				    SET @NotDesc = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc				
				END
				ELSE
				BEGIN
					SET @Success = 0;
					SET @Message = 'The company name is already exists.'	
				END
			END
		ELSE 
			BEGIN
				IF NOT EXISTS(SELECT CompanyID FROM company.Company WHERE CompanyID != @CompanyID AND CompanyName = @Name AND [Address] = @Address)	
				BEGIN		

					UPDATE [company].[Company] SET
					CompanyName = @Name,
					CompanyType = @Type,
					Address = @Address,
					PhoneNumber = @PhoneNo,
					ContactID = @ContactID
					WHERE CompanyID = @CompanyID				

					IF NOT EXISTS(SELECT ID FROM company.CompanyAndContactPerson WHERE CompanyID = @CompanyID AND ContactID = @ContactID AND IsActive = 1)
					BEGIN
						UPDATE company.CompanyAndContactPerson SET
						IsActive = 0
						WHERE CompanyID = @CompanyID

						INSERT INTO company.CompanyAndContactPerson(CompanyID, ContactID, IsActive)
						SELECT @CompanyID, @ContactID, 1
					END						

					SET @Success = 1;
					SET @Message = 'Company has been updated successfully.'

					SET @Title  = 'Company: ' + @Name + ' has updated'
					
					SET @NotDesc = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
				END
				ELSE
				BEGIN
					SET @Success = 0;
					SET @Message = 'The company name is already exists.'	
				END
			END	
	END TRY
	BEGIN CATCH
		SET @Success = 0;
		SET @Message = ERROR_MESSAGE();
	END CATCH

	SELECT @Success Success, @Message Message
END

