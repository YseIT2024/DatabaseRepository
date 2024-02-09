
CREATE Proc [room].[spRoomDetailsPageLoad]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT rt.SubCategoryID
	,rt.[Name]  [RoomType]
	FROM  Products.SubCategory rt where CategoryID=1 AND rt.IsActive=1
	ORDER BY rt.[Description]

	SELECT f.FloorID, f.[Floor]
	FROM  Products.Floor f

	SELECT LocationID,LocationName from  general.Location

	SELECT rs.RoomStatusID, rs.RoomStatus 
	FROM  Products.RoomStatus rs
END











