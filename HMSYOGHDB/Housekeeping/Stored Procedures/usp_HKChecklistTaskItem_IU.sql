
CREATE PROC [Housekeeping].[usp_HKChecklistTaskItem_IU]
    @ChecklistITaskItemId int,
    @ChecklistTaskId int,
	@ChecklistTaskItemName nvarchar(50),
    @ChecklistTaskItemDescription nvarchar(200),
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
				(SELECT * FROM [Housekeeping].[HKChecklistTaskItem] WHERE ChecklistITaskItemId = @ChecklistITaskItemId)
				Begin
				UPDATE [Housekeeping].[HKChecklistTaskItem]
				SET   ChecklistTaskItemName = @ChecklistTaskItemName, ChecklistTaskItemDescription = @ChecklistTaskItemDescription, IsActive = @IsActive, 
				       ModifiedBy = @userId ,ModifiedOn= GETDATE()
				WHERE  ChecklistITaskItemId = @ChecklistITaskItemId
				SET @IsSuccess = 1; --success 
				SET @Message = 'Task Item Updated Successfully.';
				End
			
			ELSE
			Begin
				Insert Into [Housekeeping].[HKChecklistTaskItem] ([ChecklistTaskId],[ChecklistTaskItemName],[ChecklistTaskItemDescription], [IsActive], [CreatedBy], [CreatedOn])
			                       Values (@ChecklistTaskId,@ChecklistTaskItemName,@ChecklistTaskItemDescription,@IsActive,@userId,GETDATE())

			   SET @ChecklistITaskItemId = SCOPE_IDENTITY();
			SET @IsSuccess = 1; --success
			SET @Message = 'Task Item Created Successfully.'
			End
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
