
CREATE PROCEDURE [reservation].[spGetReservationType]
(	
	@ReservationID int
)
AS
BEGIN
	SELECT ReservationTypeID
	FROM [reservation].[Reservation] 
	WHERE ReservationID = @ReservationID
END
