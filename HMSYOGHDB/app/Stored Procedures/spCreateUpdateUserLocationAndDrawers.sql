

CREATE Proc [app].[spCreateUpdateUserLocationAndDrawers] --0,0,'12334','123',null,'123',2,0,1,1
(	
	@UserID INT,
	@LocationIDs as [app].[dtLocationAndDrawer] readonly,
	@DrawerIDs as [app].[dtLocationAndDrawer] readonly,	
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
			 DELETE FROM app.UserAndLocation WHERE UserID=@UserID 
			 DELETE FROM app.UserDrawer WHERE UserID=@UserID 
			
			
			INSERT INTO app.UserAndLocation(UserID,LocationID,IsPrimary)
			SELECT @UserID, [ID], [IsPrimary] FROM @LocationIDs

			INSERT INTO app.UserDrawer(UserID,DrawerID,IsPrimary)
			SELECT @UserID, [ID], [IsPrimary] FROM @DrawerIDs

			SET @Message = 'Locations and Drawers has been updated successfully.';	
			 	 
			DECLARE @Location VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
			DECLARE @User VARCHAR(200) = (SELECT d.FirstName + ' '+ ISNULL(d.LastName,'') LastName	
			FROM app.[User] u 
			INNER JOIN contact.[Details] d ON u.ContactID=d.ContactID
			WHERE u.UserID = @UserID)

 			DECLARE @Title varchar(200) = 'LocationAndDrawer: ' + @User + ' Location and Drawers are updated'
			DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '.  By User ID:' + CAST(@EnteredBy as varchar(10));
			EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
			
			
			
		END		
		 SET @IsSuccess = 1;
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
			BEGIN
				SET @Message = 'Locations and Drawers have been updated successfully.';
			END
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@EnteredBy	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END












