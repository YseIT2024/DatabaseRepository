
CREATE PROCEDURE [Housekeeping].[HKDisposeTypeList_select] 
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT  LocationId,  DisposeTypeID,  DisposeTypeName	,IsActive	,CreatedBy	,CreatedOn , ModifiedBy, ModifiedOn		
	FROM [Housekeeping].[DisposeType]
	order by DisposeTypeID DESC     ------Added by sravani  -------
	
END
