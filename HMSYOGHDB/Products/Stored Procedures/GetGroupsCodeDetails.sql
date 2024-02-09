
CREATE Proc [Products].[GetGroupsCodeDetails]
(
@CategoryId int=0
)
AS
BEGIN
			--Declare @CategoryId int=1;
			select ISNULL(GroupID,0)GroupID,ISNULL(GroupCode,'')GroupCode,ISNULL(Description,'')Description,Name as CategoryName 
			from Products.Groups PG
			inner join Products.Category PC on PC.CategoryID=PG.CategoryID
			where PG.CategoryID=@CategoryId
			
END
