
CREATE PROCEDURE [Housekeeping].[HKDespatchList_select] 
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT  LocationId, DespatchTypeID, DespatchTypeName		,IsActive	,CreatedBy	,CreatedOn ,isnull(ModifiedBy,0) as ModifiedBy , ModifiedOn		
	FROM [Housekeeping].[DespatchType]
	order by DespatchTypeID DESC ----Added by sravani-----------
	
END
Select * from [Housekeeping].[DespatchType]



DELETE FROM [Housekeeping].[DespatchType]
WHERE DespatchTypeID=12;
