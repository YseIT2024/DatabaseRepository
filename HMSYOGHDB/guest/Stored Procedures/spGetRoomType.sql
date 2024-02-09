
CREATE proc guest.spGetRoomType
as
begin
select 0 as SubCategoryId,'All' as SubCategory
union
select SubCategoryId,[Name] as SubCategory from Products.SubCategory where CategoryID=1 and IsActive=1
end