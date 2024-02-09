CREATE proc [company].[spGetCorporateItems]
as
begin
select distinct 
b.ItemID ,
a.Name RoomType,
b.ItemName

from Products.SubCategory a 
inner join  Products.Item b on a.SubCategoryID=b.SubCategoryID where a.CategoryID=1 and a.IsActive=1
order by 1
end