
CREATE PROCEDURE [Housekeeping].[HKChecklistITask_Select] 
	@ChecklistTypeId int=null,
	@UserId int =null
AS

		DECLARE @UserDepartmentId INT=NULL;	

      IF @ChecklistTypeId > 0
			BEGIN
				SET NOCOUNT ON;
	          
				SELECT  HCT.ChecklistTaskId,HCT.ChecklistTaskName,HCT.ChecklistTaskDescription,HCT.CreatedBy,HCT.CreatedOn,HCT.IsActive,HCL.ChecklistName,HCT.ChecklistId	
				FROM [Housekeeping].[HKChecklistTask] HCT
				INNER join [Housekeeping].[HKChecklist] HCL ON HCT.ChecklistId=HCL.ChecklistId	
				where HCT.ChecklistId=@ChecklistTypeId
				ORDER BY HCT.ChecklistTaskId	
	
			END
		ELSE
			BEGIN
			select @UserDepartmentId=CD.DepartmentId from contact.Details CD
					INNER JOIN app.[User] AU ON CD.ContactID=AU.ContactID
					WHERE au.UserID=@userId 
			
			SELECT  HCT.ChecklistTaskId,HCT.ChecklistTaskName,HCT.ChecklistTaskDescription,HCT.CreatedBy,HCT.CreatedOn,HCT.IsActive,HCL.ChecklistName,HCT.ChecklistId	
				FROM [Housekeeping].[HKChecklistTask] HCT
				INNER join [Housekeeping].[HKChecklist] HCL ON HCT.ChecklistId=HCL.ChecklistId	
				WHERE HCL.ChecklistDepartmentId= @UserDepartmentId
				--where HCT.ChecklistId=@ChecklistTypeId
				ORDER BY HCT.ChecklistTaskId	
			END










