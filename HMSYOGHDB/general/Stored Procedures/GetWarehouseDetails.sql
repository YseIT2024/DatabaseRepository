-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [general].[GetWarehouseDetails] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT [WarehouseID],[Code] ,[Description],[Address],[Remarks],[IsActive]
    FROM  [general].[Warehouse] 

  SELECT [LocationID], [LocationName]
  FROM  [general].[Location] WHERE [LocationTypeID] IN (1,2,3)

  SELECT locMap.[ID] LocationMapID, locMap.[LocationID],locMap.[WarehouseID], loc.[LocationName]
  FROM  [general].[WarehouseLocationMap] locMap
  INNER JOIN  [general].[Location] loc
  ON locMap.[LocationID] = loc.[LocationID]

END



