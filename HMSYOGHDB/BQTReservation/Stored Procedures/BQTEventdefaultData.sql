CREATE PROCEDURE [BQTReservation].[BQTEventdefaultData]
AS
BEGIN
    SELECT LocationID,LocationName
    FROM general.Location 

	Select EventTypeId, EventTypeName from [BQTReservation].[EventTypeMasters] where ParentEventTypeId>0

	
	SELECT rt.SubCategoryID
	,rt.[Name]  [RoomType]
	FROM  Products.SubCategory rt where CategoryID=1 AND rt.IsActive=1
	ORDER BY rt.[Description]
    
END
