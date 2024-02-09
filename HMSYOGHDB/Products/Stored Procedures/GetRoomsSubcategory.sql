CREATE proc [Products].[GetRoomsSubcategory] --45
(
@SubCategoryID int=0
)
as
Begin
select 0 as SubCategoryId,'All' as SubCategory
union
select SubCategoryId,[Name] as SubCategory from Products.SubCategory where CategoryID=1 and IsActive=1

   if @SubCategoryID is null or @SubCategoryID = 0
    begin
		SELECT 0 as RoomID,'All' as RoomNo 
		UNION ALL
		SELECT RoomNo as RoomID, CAST(RoomNo AS VARCHAR(255)) 
		FROM Products.Room;
    end
    else
    begin
	SELECT 0 as RoomID,'All' as RoomNo 
	union all
        SELECT RoomNo as RoomID, CAST(RoomNo AS VARCHAR(255)) 
        from Products.Room   
        where SubCategoryID = @SubCategoryID
    end
End

