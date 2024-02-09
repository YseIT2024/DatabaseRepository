CREATE Proc [room].[spDeactivateSpecialRate]
(
	@RateID int,
	@LocationID int,	
	@UserID int
)
AS
BEGIN	
	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);
	DECLARE @Desc varchar(250);
	DECLARE @UserName varchar(100) = (SELECT CONCAT(FirstName,' ',LastName) 
	                                 FROM [contact].[Details] d
		                             INNER JOIN [app].[User] u ON d.ContactID = u.ContactID
									 WHERE u.UserID = @UserID)
	DECLARE @Location varchar(100) = (SELECT LocationCode FROM [general].[Location] where LocationID = @LocationID) 
	
	BEGIN TRY		
		SET @Desc = 'Deactivate by user id:' + CAST(@UserID as varchar(10)) + '(' + @UserName + ')' + ' on ' + CAST(GETDATE() as varchar(50)) + ' (' + @Location + ')';

		UPDATE room.Rate 
		SET IsActive = 0 
		,Description = @Desc
		WHERE RateID = @RateID

		SET @Message = 'Room rate has been deactivated.';
															
		SET @IsSuccess = 1;		
	END TRY  
	BEGIN CATCH 	 
		SET @Message = ERROR_MESSAGE();
		SET @IsSuccess = 0; --error		
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



