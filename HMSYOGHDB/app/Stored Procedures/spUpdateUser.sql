CREATE Proc [app].[spUpdateUser] --0,0,'12334','123',null,'123',2,0,1,1
(	
	@UserID INT,
	@UserName VARCHAR(50),
	@FirstName VARCHAR(100),
	@LastName VARCHAR(100) = NULL,
	@Password VARCHAR(30),	
	@IsActive BIT,
	@LocationID INT,
	@EnteredBy INT	
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250);	
	DECLARE @ContactID INT;

	BEGIN TRY  
		BEGIN TRANSACTION
			SET @ContactID = (SELECT ContactID FROM  app.[User] WHERE UserID =@UserID)
			
			IF EXISTS(SELECT UserName FROM  app.[User] WHERE UserID != @UserID AND UserName = @UserName)
			BEGIN				
				SET @Message = 'User name / id is already existed.';															
				SET @IsSuccess = 1;
				SELECT @IsSuccess 'IsSuccess', @Message 'Message';
				return;
			END		

			UPDATE  contact.[Details] SET FirstName = @FirstName, LastName = @LastName WHERE ContactID =@ContactID				

			UPDATE  app.[User] SET UserName = @UserName,Password = @Password ,IsActive = @IsActive WHERE UserID = @UserID			 

			SET @Message = 'User has been updated successfully.';															
			SET @IsSuccess = 1;

			DECLARE @Location VARCHAR(10) = (SELECT LocationCode FROM  general.Location WHERE LocationID = @LocationID)
			DECLARE @User VARCHAR(200) = (SELECT @FirstName + ' '+ ISNULL(@LastName,'') )

			DECLARE @Title varchar(200) = 'User: ' + 'User ' + '''' + @User +'''' +' has updated'
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
		
			SET @Message = 'User has been updated successfully.';
			
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@EnteredBy	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



