CREATE PROCEDURE [Housekeeping].[HKChecklistScheduleCompletion_PageLoad] 

  @ScheduleDetailId int,
  @UserId int,
  @LocationID int

AS
BEGIN
	SET NOCOUNT ON;
	
	Select  HL.ChecklistName , HT.ChecklistTaskName ,HI.ChecklistTaskItemName ,HI.ChecklistITaskItemId,ST.Remarks,ST.Status	
	   --case when ST.Status='Done' then '1'
	   --   when ST.Status='Not Done' then '2'
	   --else '' end as Status,
	
	  ,ST.TaskCompletionId
	--,HI.ChecklistITaskItemId
	 , ROW_NUMBER() Over (partition by HT.ChecklistTaskName order by HI.ChecklistITaskItemId) As [SN]
    from Housekeeping.HKChecklist HL left join Housekeeping.HKChecklistTask HT on HL.ChecklistId =HT.ChecklistId 
    left join Housekeeping.HKChecklistTaskItem HI on HT.ChecklistTaskId =HI.ChecklistTaskId 
    left join Housekeeping.ScheduleTaskCompletion ST on HI.ChecklistITaskItemId=ST.TaskItemId
    left join HouseKeeping.ScheduleTaskAllocation SC on ST.AllocationId=SC.AllocationId
    left join Housekeeping.HKChecklistScheduleDetails HKC on SC.ScheduleDetailId=HKC.ScheduleDetailId
    where HKC.[ScheduleDetailId] = @ScheduleDetailId
    group by HL.ChecklistName ,HT.ChecklistTaskName ,HI.ChecklistTaskItemName , HI.ChecklistITaskItemId,ST.Status,ST.Remarks,ST.TaskCompletionId


	select CSD.ScheduleDetailId,
	CSD.ChecklistId, CHL.ChecklistName
	,STA.AllocationId,STA.AllocatedTo,STA.Supervisor,STA.AllocatedLocation
	 ,(select FirstName + ' ' + LastName from [contact].[Details] where ContactID = STA.[AllocatedTo]) as AllocatedName
     ,(select FirstName + ' ' + LastName from [contact].[Details] where ContactID = STA.[Supervisor]) as SupervisorName	
	 ,CSD.ScheduleDate, CSD.ScheduleFromTime,CSD.ScheduleToTime
	from [Housekeeping].[ScheduleTaskAllocation] STA
	INNER JOIN [Housekeeping].[HKChecklistScheduleDetails] CSD ON STA.ScheduleDetailId=CSD.ScheduleDetailId
	INNER JOIN [Housekeeping].[HKChecklist] CHL ON CSD.ChecklistId=CHL.ChecklistId
	WHERE STA.ScheduleDetailId= @ScheduleDetailId
END









