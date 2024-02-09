CREATE PROCEDURE [Products].[GetDefaultDetails]
(
@CategoryID int=0
)
AS
BEGIN
			--Declare @CategoryID int=1
			Declare @SubCategoryID int

			select 0 as SubCategoryID,'Select' as SubCategory
			union all
			Select SubCategoryID,Name SubCategory
			from  Products.SubCategory 
			where CategoryID=@CategoryID and IsActive=1

			select ItemTypeID,Description  ItemType
			from  Products.ItemType

			select 0 as CuisineTypeID,'Select' as Cuisine
			union all
			Select CuisineTypeID,Name Cuisine
			from  Products.CuisineType

			select 0 as GroupID,'Select' as GroupName
			union all
			select top 1 ISNULL(GroupID,0)GroupID,ISNULL(GroupCode,'')GroupName -- Top 1 is taking since gorup is removed from product creation UI
			from  Products.Groups
			where CategoryID=@CategoryID

			
			select  BrandID,Description Brand
			from  Products.Brand

			select TaxID,TaxName
			from  general.Tax


			select FeatureID,Name Features  
			from  Products.Features where CategoryID=@CategoryID and IsActive=1

			select 0 as UOMID,'Select' as UOMName
			union all
			select UOMID,Description as UOMName from  Products.UOM

			select PRI.ItemID,ItemCode,ItemName,PRC.name Category,PRS.Name SubCategory,PRB.Description Brand,PRT.Description ItemType,ISNULL(PRU.Name,'')Cuisine,ISNULL( PRF.Description,'')GroupName
			,CC.CurrencyCode,PRI.IsActive
			--,GT.TaxName
			--,PRM.Description UOM
			from  Products.Item PRI
			INNER join  Products.Category PRC on PRC.CategoryID=PRI.CategoryID
			INNER join  Products.SubCategory PRS on PRS.SubCategoryID=PRI.SubCategoryID
			INNER join  Products.Brand PRB on PRB.BrandID=PRI.BrandID
			LEFT join  Products.ItemType PRT on PRT.ItemTypeID=PRI.ItemTypeID
			LEFT join  Products.CuisineType PRU on PRU.CuisineTypeID=PRI.CuisineTypeID
			LEFT join  Products.Groups PRF on PRF.GroupID=PRI.GroupID
			LEFT join  Products.UOM PRM on PRM.UOMID=PRI.UOMID
			inner join  currency.Currency CC on CC.CurrencyID=PRI.CurrencyId
			--left join Products.Tax PT on PT.ItemID=PRI.ItemID
			--inner join  general.Tax GT on GT.TaxID=PT.TaxID
			where PRI.CategoryID=@CategoryID --and PRI.IsActive=1
			ORDER BY PRI.ItemID DESC
					   			 			
END
