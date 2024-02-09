
CREATE PROCEDURE [reservation].[spGetReservationForCheckOutByDate]
(
	@LocationID int,
	@FromDate date,
	@ToDate date,
	@DrawerID int
)
AS
BEGIN
	SELECT 0 [ReservationID], 'Select Reservation' [Reservation]

	UNION ALL

	SELECT r.[ReservationID]
	,'Guest:' + [Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' ' + [LastName] ELSE '' END) [Reservation]   
	FROM [reservation].[Reservation] r	
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID	
	WHERE r.ReservationStatusID = 3 AND (CAST(r.ExpectedCheckOut as DATE) BETWEEN @FromDate AND @ToDate) AND r.LocationID = @LocationID
END









