create PROCEDURE [Products].[sp_GetSubCategoryInventory]
AS
BEGIN
   SELECT 
      SubCategoryID,	  Name,
      ISNULL(TotalInventory, 0) AS TotalInventory,
      ISNULL(Online_Listing, 0) AS Online_Listing,
      (ISNULL(TotalInventory, 0) - ISNULL(Online_Listing, 0)) AS OffLineInventory,
      EffectiveFrom,
      EffectiveTo
   FROM [Products].[SubCategory] where CategoryID=1 and IsActive=1
END