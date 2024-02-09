CREATE Proc [app].[spCreateUser] --0,0,'12334','123',null,'123',2,0,1,1
(
	@EmployeeID INT,
	@UserID INT,
	@UserName VARCHAR(50),
	@FirstName VARCHAR(100),
	@LastName VARCHAR(100) = NULL,
	@Password VARCHAR(30),
	@LocationID INT,
	@IsActive BIT,
	@UserLocation INT,
	@EnteredBy INT,
	@DrawerIDs as [app].[dtID] readonly,
	@IsPOSUser BIT
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250);	
	DECLARE @ContactID INT;

	IF NOT EXISTS(SELECT UserID FROM app.[User] WHERE UserName = @UserName)
		BEGIN
			BEGIN TRY  
				BEGIN TRANSACTION
					 IF (@EmployeeID <> 0)
						 BEGIN
							SET @ContactID = (SELECT ContactID FROM general.Employee WHERE EmployeeID = @EmployeeID)
						 END
					 ELSE
						 BEGIN
							INSERT INTO contact.[Details](TitleID,FirstName,LastName)
							VALUES(1,@FirstName,@LastName)

							SET @ContactID = SCOPE_IDENTITY()
						 END			

					 INSERT INTO app.[User](UserName,Password,ContactID,IsActive,IsPOSUser)
					 VALUES (@UserName,@Password,@ContactID,@IsActive,@IsPOSUser)

					 SET @UserID=SCOPE_IDENTITY()

					 INSERT INTO app.UserAndLocation(UserID,LocationID,IsPrimary)
					 VALUES (@UserID,@LocationID,1)

					 INSERT INTO app.UserDrawer(UserID,DrawerID,IsPrimary)
					 SELECT @UserID,[ID],1 FROM @DrawerIDs

					 SET @Message = 'New user has been added successfully.';															
					 SET @IsSuccess = 1;

					 DECLARE @Location VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
					 DECLARE @User VARCHAR(200) = (SELECT @FirstName + ' '+ ISNULL(@LastName,'') )

 					 DECLARE @Title varchar(200) = 'User: ' + 'New user ' + '''' + @User + '''' + ' has added'
					 DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '.  By User ID:' + CAST(@EnteredBy as varchar(10));
					 EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
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
				EXEC [app].[spInsertActivityLog] 3,@UserLocation,@Act,@EnteredBy	
			END CATCH;
		END
	ELSE
		BEGIN
			SET @IsSuccess = 0;
			SET @Message = 'Username/ID already exists in the database! Please enter a unique username/ID.';
		END

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END













