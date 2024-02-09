

CREATE Proc [Restaurant].[GetMenuMaster] --2
@LocationId int
AS
Begin

	select IT.ItemID, ItemCode,ItemName,isnull(FP.Price,IT.Price) As Price,PS.Name as SubCategory,FG.Description As FoodGroup,PU.Description as UOM
	from  Products.Item IT
	inner join  Products.SubCategory PS on PS.SubCategoryID=IT.SubCategoryID
	inner join  Products.UOM PU on PU.UOMID=IT.UOMID
	left join  Products.FoodGroup FG on IT.FoodGroupID =FG.FoodGroupID
	left join  Products.FoodPrice FP on IT.ItemID =FP.ItemID and FP.LocationID =@LocationId 
	where IT.CategoryID=2 and IsActive=1

	select MD.ItemID,ItemCode,ItemName,isnull(FP.Price,IT.Price) As Price,PS.Name as SubCategory,FG.Description As FoodGroup, PU.Description as UOM
	from  Restaurant.MenuDetails MD
	inner join  Restaurant.MenuMaster MM on MM.MenuID=MD.MenuID
	inner join  Products.Item IT on IT.ItemID=MD.ItemID
	inner join  Products.UOM PU on PU.UOMID=IT.UOMID
	inner join  Products.SubCategory PS on PS.SubCategoryID=IT.SubCategoryID
	left join  Products.FoodGroup FG on IT.FoodGroupID =FG.FoodGroupID
	left join  Products.FoodPrice FP on IT.ItemID =FP.ItemID and FP.LocationID =@LocationId 
	where IT.CategoryID=2 and IT.IsActive=1 and MM.LocationID =@LocationId 

end



