
CREATE PROCEDURE [reservation].[spGetReservationForDiscount] --11389,1
(
	@FolioNumber int,
	@LocationID int
)
AS
BEGIN
	DECLARE @ReservationID int;

	SELECT @ReservationID = r.ReservationID
	FROM [reservation].[Reservation] r
	WHERE r.FolioNumber = @FolioNumber AND r.LocationID = @LocationID AND r.CompanyID = 0 AND r.ReservationStatusID IN (1,3)

	IF(@ReservationID IS NULL)
	BEGIN
		SELECT @ReservationID = r.ReservationID
		FROM [reservation].[Reservation] r
		WHERE r.FolioNumber = @FolioNumber AND r.LocationID = @LocationID AND r.CompanyID > 0 AND r.ReservationStatusID IN (1,3,4)
	END

	SELECT r.[ReservationID]	
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]		
	,rm.RoomNo
	,rt.[RoomType]	
	,CAST(dis.[AvgDiscount] as decimal(18,2)) [Discount]
	,cur.[CurrencyID]
	,rs.ReservationStatus
	,com.CompanyName
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservationStatus rs ON r.ReservationStatusID = rs.ReservationStatusID
	INNER JOIN company.Company com ON r.CompanyID = com.CompanyID
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID		
	INNER JOIN room.RoomType rt ON rm.RoomTypeID = rt.RoomTypeID
	INNER JOIN [reservation].[vwAverageDiscount] dis ON dis.ReservationID = r.ReservationID
	INNER JOIN currency.Currency cur ON rr.RateCurrencyID = cur.CurrencyID
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID		
	WHERE r.ReservationID = @ReservationID

	SELECT SUM(rat.Rate) [Amount]
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID	
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID
	WHERE r.ReservationID = @ReservationID AND rat.IsActive = 1 AND rat.IsVoid = 0
END
