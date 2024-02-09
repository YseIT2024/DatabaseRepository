-- =============================================
-- Author:		Sravani A
-- Create date: 18-09-23
-- Description:	Details of Task Allocation'
-- =============================================
CREATE PROC [Housekeeping].[usp_TaskScheduleAllocation_IU]
@AllocationId int,
@ScheduleDetailId int,
@AllocatedTo int,
@Supervisor int,
@AllocatedLocation nvarchar(50),
@UserID int,
@LocationId int
AS 
BEGIN
	
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) ='';
	DECLARE @ChecklistId INT;
 
	DECLARE @LocationCode VARCHAR(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationId);		

	BEGIN TRY		
		BEGIN TRANSACTION							
					IF(@AllocationId=NULL or @AllocationId=0)
						BEGIN		

						INSERT INTO [Housekeeping].[ScheduleTaskAllocation]
							([ScheduleDetailId],[AllocatedTo],[Supervisor],[AllocatedLocation],[CreatedOn],[CreatedBy])
						VALUES
							(@ScheduleDetailId,@AllocatedTo ,@Supervisor ,@AllocatedLocation,getdate(),@UserID)

						SET @AllocationId=SCOPE_IDENTITY();

						SET @ChecklistId=(SELECT DISTINCT HS.ChecklistId FROM Housekeeping.HKChecklistSchedule HS
						INNER JOIN Housekeeping.HKChecklistScheduleDetails HSD ON HS.ChecklistId=HSD.ChecklistId
						WHERE HSD.ScheduleDetailId= @ScheduleDetailId)

						
						INSERT INTO [Housekeeping].[ScheduleTaskCompletion]
						    ([AllocationId],[TaskItemId],[CreatedOn],[CreatedBy])
						Select  @AllocationId, HI.ChecklistITaskItemId,GETDATE(),@UserID						
						from Housekeeping.HKChecklist HL 
						left join Housekeeping.HKChecklistTask HT on HL.ChecklistId =HT.ChecklistId 
						left join Housekeeping.HKChecklistTaskItem HI on HT.ChecklistTaskId =HI.ChecklistTaskId
						where HL.[ChecklistId] = @ChecklistId
						

						

						SET @IsSuccess = 1; --success						
						SET @Message = 'Scheduled Task Allocated Successfully' ;

						END
					ELSE
						BEGIN
						UPDATE [Housekeeping].[ScheduleTaskAllocation]
						SET [AllocatedTo]=@AllocatedTo,
							[Supervisor]=@Supervisor,
							[AllocatedLocation]=@AllocatedLocation,
							[ModifiedOn]=getdate(),
							[ModifiedBy]=@UserID
						WHERE AllocationId=@AllocationId

						SET @IsSuccess = 1; --success
						SET @Message = 'Updated successfully' ;	
						
						END								
																
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
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
End;
