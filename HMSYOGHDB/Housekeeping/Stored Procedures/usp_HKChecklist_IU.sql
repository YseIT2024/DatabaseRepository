CREATE PROC [Housekeeping].[usp_HKChecklist_IU]
    @ChecklistId int,
    @ChecklistName nvarchar(50),
    @ChecklistDescription nvarchar(200),
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
		DECLARE @UserDepartmentId INT=NULL;
		select @UserDepartmentId=CD.DepartmentId from contact.Details CD
				INNER JOIN app.[User] AU ON CD.ContactID=AU.ContactID
				WHERE au.UserID=@userId 
  

		BEGIN TRY	
		BEGIN TRANSACTION
			IF EXISTS
				(SELECT * FROM [Housekeeping].[HKChecklist] WHERE ChecklistId = @ChecklistId)
				Begin
				UPDATE [Housekeeping].[HKChecklist]
				SET    ChecklistName = @ChecklistName, ChecklistDescription = @ChecklistDescription, IsActive = @IsActive, 
				       ModifiedBy = @userId ,CreatedOn= GETDATE()
				WHERE  ChecklistId = @ChecklistId
				SET @IsSuccess = 1; --success 
				SET @Message = 'CheckList Type Updated successfully.';
				End
			
			ELSE
			begin
				Insert Into [Housekeeping].[HKChecklist] 
					([ChecklistName],[ChecklistDescription],[IsActive], [CreatedBy],[CreatedOn],
					ChecklistDepartmentId,LocationId) --Added by Arabinda on 31/08/2023 to segrate the checklist for multiple department
			        Values (@ChecklistName,@ChecklistDescription,@IsActive,@userId,GETDATE(),@UserDepartmentId,@LocationID)
								   

			   SET @ChecklistId = SCOPE_IDENTITY();
			SET @IsSuccess = 1; --success
			SET @Message = 'CheckList Type Created successfully.'
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
