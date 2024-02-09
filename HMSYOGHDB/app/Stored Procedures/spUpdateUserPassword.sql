create PROCEDURE [app].[spUpdateUserPassword] --0,0,'12334','123',null,'123',2,0,1,1
(	
	@UserID INT,
	@Password VARCHAR(30),	
	@IsActive BIT=1,
	@LocationID INT,
	@EnteredBy INT=0	
)
AS
BEGIN
   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250);	
	DECLARE @ContactID INT;
	DECLARE @User varchar(250);	

	BEGIN TRY  
		BEGIN TRANSACTION
	 
	    SET   @ContactID=(Select ContactID from  app.[User] where UserID=@UserID)
        SET @User =(Select FirstName from contact.Details where ContactID=@ContactID)
			UPDATE  app.[User] SET Password = @Password ,IsActive = 1 WHERE UserID = @UserID			 

			SET @Message = 'Password has been updated successfully.';															
			SET @IsSuccess = 1;

			DECLARE @Location VARCHAR(10) = (SELECT LocationCode FROM  general.Location WHERE LocationID = @LocationID)
			--DECLARE @User VARCHAR(200) = (SELECT @FirstName + ' '+ ISNULL(@LastName,'') )

			DECLARE @Title varchar(200) = 'User: ' + 'User ' + '''' + @User +'''' +' has updated'
			DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '.  By User ID:' + CAST(@UserID as varchar(10));
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
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


