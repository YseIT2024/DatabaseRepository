

CREATE PROCEDURE [room].[uspGetVacantRoom] --1
(
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @LastCheckoutDate datetime;
	declare @VacantDays int;

	SELECT r.RoomID
	,r.RoomNo	,r.SubCategoryID	,rt.[Description] + ' (' + rt.Description + ')' [RoomType]
	,r.FloorID	,f.[Floor]		,r.LocationID	,l.LocationName	,ISNULL(r.Dimension, '') as Dimension 	
	,ISNULL(r.BedSize,'') as BedSize	,r.MaxAdultCapacity	,r.MaxChildCapacity	,r.Remarks
	,r.RoomStatusID	,pr.RoomStatus	,r.IsActive	,r.CreateDate	,rt.Name
	,(SELECT LastCheckoutDate=max(ToDate) FROM [Products].[RoomLogs] where [RoomID]= r.RoomID and RoomStatusID in (8)) as LastCheckoutDate
	, @VacantDays
  --GROUP by [RoomID]
  --order by [RoomID]
	FROM Products.Room r
	INNER JOIN Products.SubCategory rt ON r.SubCategoryID = rt.SubCategoryID
	INNER JOIN Products.[Floor] f ON r.FloorID = f.FloorID	
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
	INNER JOIN Products.RoomStatus pr ON r.RoomStatusID = pr.RoomStatusID
	--INNER JOIN room.Feature rf ON r.FeatureID = rf.FeatureID
	WHERE --r.LocationID = @LocationID AND 
	r.IsActive =1 and r.RoomStatusID=1 
	ORDER BY r.RoomNo
END










