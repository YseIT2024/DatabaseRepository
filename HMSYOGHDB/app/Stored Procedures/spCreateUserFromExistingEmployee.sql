
CREATE PROCEDURE [app].[spCreateUserFromExistingEmployee]
(
	@EmployeeID INT,	
	@UserName VARCHAR(50),	
	@Password VARCHAR(30),	
	@IsActive BIT,
	@UserLocation INT,
	@EnteredBy INT
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250);	
	DECLARE @ContactID int;
	DECLARE @FirstName varchar(100);
	DECLARE @LastName varchar(100);
	DECLARE @UserID int;
	DECLARE @DrawerID int;

	IF NOT EXISTS(SELECT UserID FROM app.[User] WHERE UserName = @UserName)
		BEGIN
			BEGIN TRY  
				BEGIN TRANSACTION	
					SET @DrawerID = (SELECT TOP 1 DrawerID FROM app.Drawer WHERE LocationID = @UserLocation AND IsActive = 1);
							 
					SELECT @ContactID = e.ContactID, @FirstName = FirstName, @LastName = LastName 
					FROM person.[Employee] e
					INNER JOIN contact.Details cd ON e.ContactID = cd.ContactID
					WHERE EmployeeIDNumber = @EmployeeID			 		

					INSERT INTO app.[User]
					(UserName, [Password], ContactID, IsActive)
					VALUES(@UserName, @Password, @ContactID, @IsActive)

					SET @UserID = SCOPE_IDENTITY();

					INSERT INTO app.UserAndLocation(UserID,LocationID,IsPrimary)
					VALUES (@UserID,@UserLocation,1)

					INSERT INTO app.UserDrawer
					(UserID,DrawerID,IsPrimary)
					VALUES(@UserID,@DrawerID,1)

					SET @Message = 'New user has been added successfully.';															
					SET @IsSuccess = 1;

					DECLARE @Location VARCHAR(10) = (SELECT LocationCode FROM general.[Location] WHERE LocationID = @UserLocation)
					DECLARE @User VARCHAR(200) = (SELECT @FirstName + ' ' + ISNULL(@LastName,'') )

					DECLARE @Title varchar(200) = 'User: ' + 'New user ' + '''' + @User + '''' + ' has added'
					DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '.  By User ID:' + CAST(@EnteredBy as varchar(10));

					EXEC [dbo].[spInsertIntoNotification] @UserLocation, @Title, @NotDesc	
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
					SET @Message = 'New user has been added successfully.';	
				END;  

				---------------------------- Insert into activity log---------------	
				DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog] 3, @UserLocation, @Act, @EnteredBy	
			END CATCH;
		END
	ELSE
		BEGIN
			SET @IsSuccess = 0;
			SET @Message = 'Username/ID already exists in the database! Please enter a unique username/ID.';
		END

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END

