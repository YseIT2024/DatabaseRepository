CREATE Proc [app].[spUpdateUserRoleObjects] --1,5,1,1509
(
	@UserRoleObjects AS [app].[dtObjectAccess] READONLY,
	@RoleID INT,
	@EnterBy INT,
	@LocationID INT
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);
		
	BEGIN TRY  
		BEGIN TRANSACTION
			DELETE FROM  app.UserRoleObjects WHERE RoleID = @RoleID

			IF ((SELECT COUNT([ObjectID]) FROM @UserRoleObjects) > 0)
			BEGIN
				INSERT INTO  app.UserRoleObjects(RoleID,ObjectID,OperationID)
				SELECT @RoleID , [ObjectID],[OperationID] FROM @UserRoleObjects
			END

			SET @IsSuccess = 1;
			SET @Message = 'UserRoleObjects has been changed successfully.';	
			
			DECLARE @Location VARCHAR(10) = (SELECT LocationCode FROM  general.Location WHERE LocationID = @LocationID)
			DECLARE @Role VARCHAR(50) = (SELECT [Role] FROM  app.Roles WHERE RoleId = @RoleID)

 			DECLARE @Title varchar(200) = 'RoleObjects: ' + @Role + ' objects are updated'
			DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '.  By User ID:' + CAST(@EnterBy as varchar(10));
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
			SET @Message =  'User Role Objects has been changed successfully.';	
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@EnterBy	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



