
CREATE Proc [Products].[GetGroupsCodeDetailsForUpdate]
(
@GroupID int=0
)
AS
BEGIN
			--Declare @GroupID int=14;
			select GroupID, GroupCode,Description,CategoryID 
			from Products.Groups 
			where GroupID=@GroupID
			
END
