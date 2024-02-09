
CREATE PROCEDURE [report].[spGetAdvancePayment]
(
	@ReservationID int,
	@LocationID int = null,
	@DrawerID int = null,
	@UserID int = null
) 
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT
	(l.LocationCode + CAST(r.FolioNumber as varchar(20))) FolioNumber
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') as [CheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') as [CheckOut]
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [Name]
	,bill.[Nights]
	,CAST(CAST(ISNULL([AvgDiscount],0) as decimal(18,2)) as varchar(6)) + '%' [Discount]
	,bill.TotalAmount
	,bill.AvgRate
	,bill.DiscountAmount
	,rm.RoomNo
	,(SELECT account.fnGetAdvancePayment(r.ReservationID)) Advance
	,rr.RateCurrencyID
	FROM [reservation].[Reservation] r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room rm ON rr.RoomID = rm.RoomID
	INNER JOIN [reservation].[vwAverageDiscount] dis ON dis.ReservationID = r.ReservationID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	CROSS APPLY [reservation].[fnGetReservationRoomBill](r.ReservationID) bill
	WHERE r.ReservationID = @ReservationID

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Advance Payment Receipt', @UserID
END

