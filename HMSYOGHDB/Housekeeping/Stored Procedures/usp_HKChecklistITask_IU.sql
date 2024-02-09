
CREATE PROC [Housekeeping].[usp_HKChecklistITask_IU]
    @ChecklistTaskId int,
    @ChecklistId int,
	@ChecklistTaskName nvarchar(50),
    @ChecklistTaskDescription nvarchar(200),
	@IsActive Bit, 
    @userId int,   
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
				(SELECT * FROM [Housekeeping].[HKChecklistTask] WHERE ChecklistTaskId = @ChecklistTaskId)
				Begin
				UPDATE [Housekeeping].[HKChecklistTask]
				SET    ChecklistId=@ChecklistId, ChecklistTaskName = @ChecklistTaskName, ChecklistTaskDescription = @ChecklistTaskDescription, IsActive = @IsActive, 
				       ModifiedBy = @userId ,ModifiedOn= GETDATE()
				WHERE  ChecklistTaskId = @ChecklistTaskId
				SET @IsSuccess = 1; --success 
				SET @Message = 'Updated successfully.';
				end
			ELSE
				Begin
				Insert Into [Housekeeping].[HKChecklistTask] ([ChecklistId],[ChecklistTaskName],[ChecklistTaskDescription], [IsActive], [CreatedBy], [CreatedOn])
			                       Values (@ChecklistId,@ChecklistTaskName,@ChecklistTaskDescription,@IsActive,@userId,GETDATE())

				SET @ChecklistTaskId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'Created Successfully.'
				end
			EXEC [app].[spInsertActivityLog] 7,@LocationID,@userId
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
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@userId	
	END CATCH;  
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END	
