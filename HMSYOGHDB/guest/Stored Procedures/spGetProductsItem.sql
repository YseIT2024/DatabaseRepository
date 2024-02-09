
-- =============================================
-- Author:          <ARABINDA PADHI>
-- Create date: <27/01/2023>
-- Description:     <TO GET THE PRODUCTS.ITEM DETAILS>
-- =============================================

CREATE Proc [guest].[spGetProductsItem] 
(		
	@SubCategoryID INT,	
    @UserId varchar(50) = 0     
)
AS
BEGIN
	--SET NOCOUNT ON prevents the sending of DONEINPROC messages to the client for each statement in a stored procedure
	SET NOCOUNT ON;

	IF(@SubCategoryID <> 0)
		BEGIN
			SELECT A.ItemID, A.ItemCode, A.ItemName, A.CategoryID, A.SubCategoryID, A.BrandID, A.ItemTypeID,A.CuisineTypeID, 
				A.GroupID, A.UOMID, A.Price, A.CurrencyId, A.MaxDiscount, A.ReorderLevel, A.BarcodeValue, A.Remarks, A.IsActive,
				A.IsListed, A.CreatedBy, A.CreateDate,B.Code,B.[Name],B.[Description], B.Remarks, B.MaxReservingCapacity, B.MaxChildAge
			FROM [HMSYOGH].[Products].[Item] A
			INNER JOIN [HMSYOGH].[Products].[SubCategory] B ON A.[SubCategoryID]=B.SubCategoryID
			WHERE A.SubCategoryID=@SubCategoryID;
		END
	ELSE
		BEGIN
		SELECT A.ItemID, A.ItemCode, A.ItemName, A.CategoryID, A.SubCategoryID, A.BrandID, A.ItemTypeID,A.CuisineTypeID, 
				A.GroupID, A.UOMID, A.Price, A.CurrencyId, A.MaxDiscount, A.ReorderLevel, A.BarcodeValue, A.Remarks, A.IsActive,
				A.IsListed, A.CreatedBy, A.CreateDate,B.Code,B.[Name],B.[Description], B.Remarks, B.MaxReservingCapacity, B.MaxChildAge
			FROM [HMSYOGH].[Products].[Item] A
			INNER JOIN [HMSYOGH].[Products].[SubCategory] B ON A.[SubCategoryID]=B.SubCategoryID;
		END	
END



	
