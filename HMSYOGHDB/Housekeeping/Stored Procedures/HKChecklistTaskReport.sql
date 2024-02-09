



CREATE PROCEDURE [Housekeeping].[HKChecklistTaskReport] 

  @ChecklistId INT,
  @LocationID int=null

AS
BEGIN
	SET NOCOUNT ON;
	
	Select  HL.ChecklistName , HT.ChecklistTaskName ,HI.ChecklistTaskItemName ,HI.ChecklistITaskItemId

	--,HI.ChecklistITaskItemId
	   ,ROW_NUMBER() Over (partition by HT.ChecklistTaskName order by HI.ChecklistITaskItemId) As [SN]
    from Housekeeping.HKChecklist HL left join Housekeeping.HKChecklistTask HT on HL.ChecklistId =HT.ChecklistId 
     left join Housekeeping.HKChecklistTaskItem HI on HT.ChecklistTaskId =HI.ChecklistTaskId 
     where HL.[ChecklistId] = @ChecklistId
    group by HL.ChecklistName ,HT.ChecklistTaskName ,HI.ChecklistTaskItemName , HI.ChecklistITaskItemId

END










