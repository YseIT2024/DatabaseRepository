CREATE PROCEDURE [reservation].[spGetDetailsToChangeBillTo]
(
	@FolioNumber int,
	@LocationID int
)
AS
BEGIN
	SELECT r.[ReservationID]	
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]	
	,com.CompanyName [BillTo]	
	,rm.RoomNo
	,r.CompanyID
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID		
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID	
	INNER JOIN [company].[Company] com on r.CompanyID = com.CompanyID
	WHERE r.FolioNumber = @FolioNumber AND r.LocationID = @LocationID AND ReservationStatusID IN (1,3)

	SELECT CompanyID, CompanyName
	FROM company.Company
END

