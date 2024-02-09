-- =============================================
-- Author:		Sravani A
-- Create date: 20-09-23
-- Description:	Details of Task Completion'
-- =============================================
CREATE PROC [Housekeeping].[usp_TaskScheduleCompletion_IU]
@AllocationId int,
@Remarks nvarchar(100)=null,
@Status nvarchar(100)=null,
@CompletedBy nvarchar(150),
@VerifiedBy nvarchar(150),
@UserID int,
@LocationId int,
@HKChecklistTaskItem as [Housekeeping].[dtScheduleCompletionDetails] READONLY
AS 
BEGIN
	
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) ='';
 
	DECLARE @LocationCode VARCHAR(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationId);		

	BEGIN TRY		
		--BEGIN TRANSACTION							
					--IF(@TaskCompletionId=0)
					--	BEGIN		

					--	--INSERT INTO [Housekeeping].[ScheduleTaskCompletion]
					--	--	([AllocationId],[TaskItemId],[Remarks],[Status],[CompletedBy],[VerifiedBy],[CreatedOn],[CreatedBy])
					--	--VALUES
					--	--	(@AllocationId,@TaskItemId ,@Remarks ,@Status,@CompletedBy,@VerifiedBy,getdate(),@UserID)

     -- --                  --SET @TaskCompletionId = SCOPE_IDENTITY(); 
					--	----INSERT INTO [Housekeeping].[HKChecklistTaskItem]
					--	----			([ChecklistTaskId],[ChecklistITaskItemId],[Status],[Remarks],
					--	----			[CreatedBy],[Createdon]) 
					--	----select @ChecklistTaskId,@ChecklistITaskItemId,Status,Remarks,
					--	----		@userId, GETDATE()
					--	----from @HKChecklistTaskItem


					--DECLARE @ID INT;
					--DECLARE myCursor CURSOR FOR select ChecklistITaskItemId from @HKChecklistTaskItem 
					--OPEN myCursor;
					--FETCH NEXT FROM myCursor INTO @ID;
					--WHILE @@FETCH_STATUS = 0
					--BEGIN

					 --UPDATE [Housekeeping].[HKChecklistTaskItem] SET [Status]=(select [Status] from @HKChecklistTaskItem WHERE ChecklistITaskItemId=@ID) 
					 --,Remarks=(select Remarks from @HKChecklistTaskItem WHERE ChecklistITaskItemId=@ID)
					 --WHERE ChecklistITaskItemId=@ID

					 --UPDATE [Housekeeping].[ScheduleTaskCompletion]
						--SET [Remarks]=@Remarks,
						--    [Status]=@Status,
						--	[CompletedBy]=@CompletedBy,
						--	[VerifiedBy]=@VerifiedBy,
						--	[ModifiedOn]=getdate(),
						--	[ModifiedBy]=@UserID
						--WHERE TaskCompletionId=@TaskCompletionId

						UPDATE [Housekeeping].[ScheduleTaskCompletion]							
						SET 
							[Remarks]=HKC.Remarks,
						    [Status]=HKC.Status,
							[CompletedBy]=@CompletedBy,
							[VerifiedBy]=@VerifiedBy,
							[ModifiedOn]=getdate(),
							[ModifiedBy]=@UserID
							
						FROM 
							[Housekeeping].[ScheduleTaskCompletion]	HS
							INNER JOIN  @HKChecklistTaskItem HKC ON HS.TaskCompletionId=HKC.TaskCompletionId      -----HKC.TaskCompletionId
						--WHERE 
							--HS.TaskCompletionId;
						
						

					--FETCH NEXT FROM myCursor INTO @ID;
					--END
					--CLOSE myCursor;
					--DEALLOCATE myCursor;
						
					--	--INSERT INTO [Housekeeping].[HKChecklistTaskItem]
					--	--			([ChecklistTaskId],[ChecklistITaskItemId],[Status],[Remarks],
					--	--			[CreatedBy],[Createdon]) 
					--	--select @ChecklistTaskId,@ChecklistITaskItemId,Status,Remarks,
					--	--		@userId, GETDATE()
					--	--from @HKChecklistTaskItem

					--	SET @IsSuccess = 1; --success						
					--	SET @Message = 'Scheduled Task Completed Successfully' ;

					--	END
					--ELSE
					--	BEGIN
					--	UPDATE [Housekeeping].[ScheduleTaskCompletion]
					--	SET [Remarks]=@Remarks,
					--	    [Status]=@Status,
					--		[CompletedBy]=@CompletedBy,
					--		[VerifiedBy]=@VerifiedBy,
					--		[ModifiedOn]=getdate(),
					--		[ModifiedBy]=@UserID
					--	WHERE TaskCompletionId=@TaskCompletionId

						SET @IsSuccess = 1; --success
						SET @Message = 'Updated successfully' ;	
						
					--	END								
																
		--COMMIT TRANSACTION					
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
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
End;

