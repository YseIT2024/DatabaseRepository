CREATE Proc [app].[spCreateUpdateUserRoles] --0,0,'12334','123',null,'123',2,0,1,1
(	
	@UserID INT,
	@RoleIDs as [app].[dtID] readonly,		
	@LocationID INT,	
	@EnteredBy INT	
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);	
	DECLARE @ContactID INT

	BEGIN TRY  
		BEGIN TRANSACTION		
			BEGIN
				DELETE  FROM [app].[UsersAndRoles] WHERE UserID = @UserID

				IF ((SELECT COUNT(ID) FROM @RoleIDs) > 0)
				BEGIN
					INSERT INTO [app].[UsersAndRoles]
					(UserID,RoleID)
					SELECT @UserID,[ID] FROM @RoleIDs
				END

				DECLARE @Location VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
				DECLARE @User VARCHAR(200) = (SELECT d.FirstName + ' '+ ISNULL(d.LastName,'') 	
				FROM app.[User] u 
				INNER JOIN contact.[Details] d ON u.ContactID=d.ContactID
				WHERE u.UserID = @UserID)

 				DECLARE @Title varchar(200) = 'UserRoles: ' + @User + ' user roles are updated'
				DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '.  By User ID:' + CAST(@EnteredBy as varchar(10));
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
			END
		
			SET @IsSuccess = 1;
			SET @Message = 'User Roles has been updated successfully.';			
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
			SET @Message = 'User Roles has been updated successfully.';			
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@EnteredBy	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



