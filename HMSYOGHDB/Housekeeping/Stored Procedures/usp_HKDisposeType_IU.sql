


CREATE PROC [Housekeeping].[usp_HKDisposeType_IU]

	@DisposeTypeId int,
	@DisposeTypeName varchar (50),  
	@IsActive Bit, 
    @UserId int,   
	@LocationID int
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';
		--DECLARE @ContactID int;
		--DECLARE @GenderID int;
		--Declare @ImageID int;
		DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
		--DECLARE @Title varchar(200);
		--DECLARE @Actvity varchar(max);  
  

		BEGIN TRY	
		BEGIN TRANSACTION
			IF EXISTS
				(SELECT * FROM [Housekeeping].[DisposeType] WHERE DisposeTypeId = @DisposeTypeId)
				Begin	
				UPDATE [Housekeeping].[DisposeType] SET
					DisposeTypeName=@DisposeTypeName,IsActive=@IsActive
					,ModifiedBy=@UserId,ModifiedOn=GETDATE()
					WHERE DisposeTypeId=@DisposeTypeId

				SET @IsSuccess = 1; --success 
				SET @Message = 'DisposeType Updated Successfully.';
				End
				
			
			ELSE
			BEGIN
				
				INSERT INTO [Housekeeping].[DisposeType]
							([LocationId],[DisposeTypeName],[IsActive],[CreatedBy],[CreatedOn])
				VALUES(@LocationID, @DisposeTypeName,@IsActive, @UserId, GETDATE())


				SET @DisposeTypeId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'DisposeType Inserted successfully.'
			
			
			END

			EXEC [app].[spInsertActivityLog] 7,@LocationID,@UserId
	COMMIT TRANSACTION			
	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END; 		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@UserId	
	END CATCH;  
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END	
