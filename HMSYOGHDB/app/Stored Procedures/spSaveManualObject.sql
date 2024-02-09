CREATE Proc [app].[spSaveManualObject]
(
	@TabGroupID int,
	@LocationID int,
	@UserID int,
	@DisplayText varchar(150),
	@ObjectName varchar(150),
	@ObjectPath varchar(250)
)
AS
BEGIN	   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250);

	IF(@TabGroupID = 0)
	BEGIN
		SET @TabGroupID = NULL;
	END

	BEGIN TRY
		IF NOT EXISTS (SELECT ObjectID FROM  [app].[Object] WHERE TabGroupID = @TabGroupID AND ObjectName = @ObjectName AND ObjectPath = @ObjectPath)
			BEGIN
				INSERT INTO  [app].[Object]
				(TabGroupID, ObjectName, DisplayText, ObjectPath, IsAutoObject)
				SELECT @TabGroupID, @ObjectName, @DisplayText, @ObjectPath, 0	

				SET @IsSuccess = 1; --success  			
				SET @Message = 'Object has been saved successfully.';
			END 					
		ELSE
			BEGIN
				SET @IsSuccess = 0; --exists  			
				SET @Message = 'Object name exists under the same tab group and path. Please try a unique object name.';
			END 					
	END TRY  
	BEGIN CATCH  		
		SET @Message = ERROR_MESSAGE();
		SET @IsSuccess = 0; --error
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



