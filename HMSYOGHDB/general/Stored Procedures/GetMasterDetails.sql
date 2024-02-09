
CREATE Proc [general].[GetMasterDetails] --5
(
	@TableId int,
	@CategoryID int = 0,
	@SubCategoryID int = 0
)
AS
BEGIN
	IF(@TableId=1)
	  Select DepartmentID as ID,Department as Description,null as Code  from  general.Department ORDER BY Department
	else IF(@TableId=2)
	  Select DesignationID as ID,Designation as Description,null as Code from  general.Designation ORDER BY Designation
	else If(@TableId=3)
	  Select RoleId as ID,[Role] as Description,null as Code from  app.Roles ORDER BY Role
	else If(@TableId=4)
		select 0  as LocationID,'Select' as LocationName
		union all
		select LocationID ,LocationName  from  general.Location where LocationTypeID in(2,3)
   else If(@TableId=5)
        select CategoryID as ID , [Name] as Description,Code as Code from  Products.Category where CategoryID=1
	else If(@TableId=6)
        select [FoodGroupID] as ID , [Description],null as Code from  [Products].[FoodGroup]
	else If(@TableId=7)
        select [CuisineTypeID] as ID , [Name] as Description,null as Code from  [Products].[CuisineType]
	else If(@TableId=8)
		select [CategoryID] , [Name] from  [Products].[Category] where [CategoryID] in(2,7,10,11)
        --select [LocationTypeID] , [LocationType] from  [general].[LocationType] WHERE [CategoryID] in(2,7,10,11)
	else If(@TableId=9 and @CategoryID > 0)
	  begin
        select [LocationID] , [LocationName] from  [general].[Location] loc
		inner join  [general].[LocationType] locType on loc.LocationTypeID = locType.LocationTypeID
		WHERE locType.[CategoryID] = @CategoryID

		SELECT [MealType],[MealTypeID]
		FROM  [Restaurant].[MealType]
	 end
	 else If(@TableId=10)
		select [BrandID] as ID, [Description], null as Code from  [Products].[Brand]
	else If(@TableId=11)
		select [TaxID] as ID, [TaxName] as [Description], null as Code from  [general].[Tax]
	else If(@TableId=12)
		SELECT [LocationID], [LocationName] FROM  [general].[Location] where [LocationTypeID] = 1
	else If(@TableId=13 and @SubCategoryID > 0)
        select ItemID , [ItemName] FROM  [Products].[Item] WHERE [SubCategoryID] = @SubCategoryID	and isactive=1
END

