

CREATE PROCEDURE [room].[spGetRoomDetailsByLocation] --1
(
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT r.RoomID
	,r.RoomNo	,r.SubCategoryID	,rt.[Description] + ' (' + rt.Description + ')' [RoomType]
	,r.FloorID	,f.[Floor]		,r.LocationID	,l.LocationName	,ISNULL(r.Dimension, '') as Dimension 	
	,ISNULL(r.BedSize,'') as BedSize	,r.MaxAdultCapacity	,r.MaxChildCapacity	,r.Remarks
	,r.RoomStatusID	--	,pr.RoomStatus	
	,concat(pr.RoomStatus, '-', pr.HKStatusName) as [RoomStatus]
	,r.IsActive	,r.CreateDate	,rt.Name
	--,rf.FeatureID
	--,ISNULL(rf.Description,'') AS [Description]	
	--,ISNULL(CAST(rf.Balconies as varchar(2)), '') AS Balconies	
	--,ISNULL(rf.RoomNote,'') AS RoomNote
	FROM Products.Room r
	INNER JOIN Products.SubCategory rt ON r.SubCategoryID = rt.SubCategoryID
	INNER JOIN Products.[Floor] f ON r.FloorID = f.FloorID	
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
	INNER JOIN Products.RoomStatus pr ON r.RoomStatusID = pr.RoomStatusID
	--INNER JOIN room.Feature rf ON r.FeatureID = rf.FeatureID
	WHERE r.LocationID = @LocationID --AND r.IsActive =1
	ORDER BY r.SubCategoryID,RoomNo
END










