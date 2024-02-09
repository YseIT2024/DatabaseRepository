
CREATE PROCEDURE [reservation].[spMealPlan]
--(	
	--@SubCategoryID int
--)
AS
BEGIN
	 
	 SELECT PS.Name as RoomType ,PIT.ItemID as ItemID,PIT.ItemName as ProductName,PRP.Day as Days ,PRP.BasePrice as BasePrice FROM Products.Item PIT
			inner join Products.RoomDayPrice PRP on PIT.ItemID=PRP.ItemID
			inner join Products.SubCategory PS on PIT.SubCategoryID=PS.SubCategoryID
			where PIT.IsActive=1 and PRP.IsActive=1  --and PIT.SubCategoryID=@SubCategoryID
END


