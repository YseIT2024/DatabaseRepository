
CREATE PROCEDURE [account].[spGetGuestDetailsByFolioNo]--'STH10013'
(
	@FolioNumber varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LocationCode varchar(3) = (SELECT SUBSTRING(@FolioNumber, 1, 3));
	DECLARE @FNumber int = (SELECT CAST(STUFF(@FolioNumber, 1, 3, '') as int));
	DECLARE @LocationID int = (SELECT LocationID FROM general.Location WHERE LocationCode = @LocationCode)
	DECLARE @ReservationID int = (SELECT ReservationID FROM reservation.Reservation WHERE FolioNumber = @FNumber AND LocationID = @LocationID)
	DECLARE @Discount decimal(18,4);
	DECLARE @Compliment decimal(18,4);
	DECLARE @Void decimal(18,4);
	DECLARE @Total decimal(18,4);
	DECLARE @Other decimal(18,4);
	DECLARE @Advance decimal(18,4);

	SELECT 	@Compliment = vdcomp.ComplimentaryAmount
	--,@Void = vdcomp.VoidAmount 
	FROM [reservation].[vwReservationDetails] v		
	CROSS APPLY (SELECT * FROM [reservation].[fnGetVoidAndComplimentaryAmount](v.ReservationID))vdcomp
	WHERE v.ReservationID = @ReservationID 
	
	SELECT @Total = fn.TotalAmount
	,@Discount = fn.DiscountAmount 
	,@Other = (SELECT [account].[fnGetReservationPayment](@ReservationID))
	--,@Advance = (SELECT [account].fnGetAdvancePayment(@ReservationID)) 
	FROM [reservation].[fnGetReservationRoomBill](@ReservationID) fn

	SELECT r.GuestID
	,r.ReservationID
	,(Title + ' ' + FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName ELSE '' END) as [Name],
	ROUND(@Total - @Discount - @Other  - @Compliment, 2) [Amount],
	rm.RateCurrencyID [CurrencyID]
	FROM [reservation].[Reservation] r
	INNER JOIN [reservation].[ReservedRoom] rm ON r.ReservationID = rm.ReservationID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID 	
	INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID	
	Where r.FolioNumber = @FNumber AND l.LocationCode = UPPER(@LocationCode) AND r.ReservationStatusID IN (3,4)	

	
END

