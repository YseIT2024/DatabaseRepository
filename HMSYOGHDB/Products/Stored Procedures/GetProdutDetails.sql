

CREATE Proc [Products].[GetProdutDetails]
(
@ItemID int=0
)
AS
BEGIN
			--Declare @ItemID int=1
			
			select CategoryID,SubCategoryID,ItemCode,ItemName,ItemTypeID,isnull(CuisineTypeID,0)CuisineTypeID,isnull(GroupID,0)GroupID,BrandID,UOMID,Price,CC.CurrencyCode,MaxDiscount,Remarks,IsActive
			from Products.Item PIT
			inner join currency.Currency CC on CC.CurrencyID=PIT.CurrencyId
			where ItemID=@ItemID

			select PID.ItemID,PIT.ItemName,PID.Price,Quantity,SUB.Name
			from  Products.ItemDetails PID
			inner join Products.Item PIT on PIT.ItemID=PID.ItemID
			inner join Products.SubCategory SUB on SUB.SubCategoryID=PIT.SubCategoryID
			where ParentIemID=@ItemID

			select Isnull(FeatureID,0)FeatureID
			from  Products.ItemFeatures 
			where ItemID=@ItemID

			select isnull(TaxID,0)TaxID
			from  Products.Tax
			where ItemID=@ItemID

			select isnull(FilePath,'')ImageName
			from  Products.ItemImage
			where ItemID=@ItemID
					   			 			
END

