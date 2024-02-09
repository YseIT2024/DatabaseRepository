
CREATE PROCEDURE [app].[spChangePassword] --1,1,'1','1'
(	
	@LocationID INT,
	@UserID INT,
	@NewPassword VARCHAR(30),	
	@OldPassword VARCHAR(30)
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
		IF((SELECT [Password] FROM app.[User] WHERE UserID = @UserID) = @OldPassword)	
			BEGIN
				UPDATE [app].[User] 
				SET [Password] =@NewPassword 
				WHERE UserID = @UserID		 

				SET @Message = 'Password has been changed successfully.';															
				SET @IsSuccess = 1;
			END
		ELSE
			BEGIN
				SET @Message = 'Old password did not match. Please enter correct old password.';															
				SET @IsSuccess = 0;
			END		
	END TRY  
	BEGIN CATCH    
		SET @IsSuccess = 0;		
		SET @Message = 'Password did not update. Please try again.';
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



