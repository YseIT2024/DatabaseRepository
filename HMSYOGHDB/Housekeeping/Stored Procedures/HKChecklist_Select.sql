
CREATE PROCEDURE [Housekeeping].[HKChecklist_Select] 
  @ChecklistId int = null,
  @UserId int =null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @UserDepartmentId INT=NULL;	

	BEGIN
		IF (@ChecklistId>0)

			SELECT HKC.ChecklistId, HKC.ChecklistName ,HKC.ChecklistDescription	,HKC.CreatedBy	,HKC.CreatedOn ,HKC.IsActive	
			FROM [Housekeeping].[HKChecklist] HKC
			INNER JOIN [Housekeeping].[HKChecklist] HT ON HKC.ChecklistId = HT.ChecklistId
			where HT.ChecklistId=@ChecklistId
			ORDER BY HT.ChecklistId
		ELSE
			select @UserDepartmentId=CD.DepartmentId from contact.Details CD
					INNER JOIN app.[User] AU ON CD.ContactID=AU.ContactID
					WHERE au.UserID=@UserId 					

			SELECT HKC.ChecklistId, HKC.ChecklistName ,HKC.ChecklistDescription	,HKC.CreatedBy	,HKC.CreatedOn ,HKC.IsActive	
			FROM [Housekeeping].[HKChecklist] HKC
			INNER JOIN [Housekeeping].[HKChecklist] HT ON HKC.ChecklistId = HT.ChecklistId
			--AND HKC.ChecklistDepartmentId= @UserDepartmentId
			ORDER BY HT.ChecklistId
			
	END
	
END

