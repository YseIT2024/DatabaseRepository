-- =============================================
-- Author:		Sravani A
-- Create date: 05-09-23
-- Description:	Details of Task Scheduling'
-- =============================================
CREATE PROC [Housekeeping].[HKTaskSchedulingList_Select]	

AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON	
			
	SELECT CS.ChecklistScheduleId,CS.ChecklistId, HKC.ChecklistName,CS.FromDate,
			CS.ToDate,CS.Repeat,CS.Frequency,CS.CreatedBy,CS.CreatedOn
	FROM [Housekeeping].[HKChecklistSchedule] CS		
		  inner join [Housekeeping].[HKChecklist] HKC on CS.ChecklistId = HKC.ChecklistId
		  ORDER BY CS.CheckListScheduleId DESC		  

END	

