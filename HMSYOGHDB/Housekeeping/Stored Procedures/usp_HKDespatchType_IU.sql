
CREATE PROC [Housekeeping].[usp_HKDespatchType_IU]
	@DespatchTypeId int,
	@DespatchTypeName varchar(50),  
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
				(SELECT * FROM [Housekeeping].[DespatchType] WHERE DespatchTypeId = @DespatchTypeId)
				Begin	
				UPDATE [Housekeeping].[DespatchType] SET
					DespatchTypeName=@DespatchTypeName,IsActive=@IsActive
					,ModifiedBy=@UserId,ModifiedOn=GETDATE()
					WHERE DespatchTypeId=@DespatchTypeId

				SET @IsSuccess = 1; --success 
				SET @Message = 'DespatchType Updated Successfully.';
				End
			
			ELSE
			BEGIN
				INSERT INTO [Housekeeping].[DespatchType]
						([LocationId],[DespatchTypeName],[IsActive],[CreatedBy],[CreatedOn])
						VALUES (@LocationId,@DespatchTypeName,@IsActive,@UserId,GETDATE())
				SET @DespatchTypeId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'DespatchType Inserted successfully.'
			
			
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
