
CREATE PROCEDURE [reservation].[spGetDetailsToWriteOff]
(	
	@FolioNumber int,
	@LocationID int
)
AS
BEGIN
	SELECT r.[ReservationID]
	,r.[ReservationStatusID]
	,rs.ReservationStatus
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) [FullName]	
	,rm.RoomNo
	,rr.RateCurrencyID
	,CAST(payment.Balance as decimal(18,2)) [Balance]	
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID	
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	INNER JOIN reservation.ReservationStatus rs ON r.ReservationStatusID = rs.ReservationStatusID
	CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](r.ReservationID)) payment
	WHERE r.FolioNumber = @FolioNumber AND r.LocationID = @LocationID	
END
