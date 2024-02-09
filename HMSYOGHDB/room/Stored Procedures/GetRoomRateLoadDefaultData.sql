-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [room].[GetRoomRateLoadDefaultData] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--SELECT  [LocationID] ,[LocationName]
 --   FROM  [general].[Location] where [LocationTypeID] = 1	 
 	SELECT  [LocationID] ,[LocationName]
  FROM  [general].[Location] where [LocationID] = 1	

	SELECT [SubCategoryID] as RoomTypeID,[Name] as RoomType 
	FROM  [Products].[SubCategory] where [CategoryID] = 1 AND IsActive=1

    SELECT gt.TaxRate FROM [service].[ServiceTax] ss INNER JOIN general.Tax gt on ss.TaxID =gt.TaxID where gt.TaxID=3 AND ss.ServiceTypeID=18

END

