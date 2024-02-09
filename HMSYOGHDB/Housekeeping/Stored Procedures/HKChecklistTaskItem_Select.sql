
CREATE PROCEDURE [Housekeeping].[HKChecklistTaskItem_Select] 

  @ChecklistTaskId INT=null

AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT  r.ChecklistTaskId,	r.ChecklistITaskItemId,r.ChecklistTaskItemName	,r.ChecklistTaskItemDescription	,r.CreatedBy	,r.CreatedOn		,r.IsActive	
	,HCT.ChecklistTaskName
	FROM [Housekeeping].[HKChecklistTaskItem] r
	INNER JOIN [Housekeeping].[HKChecklistTask] HCT ON r.ChecklistTaskId = HCT.ChecklistTaskId	  
	where r.ChecklistTaskId=@ChecklistTaskId
	ORDER BY r.ChecklistITaskItemId
	
END










