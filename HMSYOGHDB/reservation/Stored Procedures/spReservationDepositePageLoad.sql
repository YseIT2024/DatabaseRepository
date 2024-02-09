create PROCEDURE [reservation].[spReservationDepositePageLoad]
(	
	@LocationID int,
	@DrawerID int
)
AS
BEGIN
    
	SELECT ReservationModeID, ReservationMode
	FROM reservation.ReservationMode where ReservationModeID <> 4 -- Online (not required fror offline reservation)

	SELECT ReservationTypeID, ReservationType
	FROM reservation.ReservationType where IsActive =1

	select 0 as RoomTypeID,'SELECT' as RoomType
	union all
	SELECT DISTINCT rt.SubCategoryID RoomTypeID, Name  RoomType
	FROM Products.SubCategory rt
	INNER JOIN Products.Room r ON rt.SubCategoryID = r.SubCategoryID
	WHERE r.LocationID = @LocationID AND r.IsActive = 1 and rt.IsActive=1 AND rt.CategoryID=1

END
