
CREATE PROCEDURE [guest].[spGetGuestVoucherHistory_Sub3]
(	
	@VoucherID int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [VoucherID]
	,[VoucherNumber]		
	,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
	,t.Title + ' ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') [GuestName]
	,c.CurrencySymbol + CAST(CAST([Amount] as decimal(18,2)) as varchar(12)) [Amount]
	,CAST(DATEDIFF(DAY, ValidFrom, ValidTo) as varchar(3)) + ' day(s) remaining.' [Valid]
	,FORMAT([ValidFrom],'dd-MMM-yyyy') [ValidFrom]
	,FORMAT([ValidTo],'dd-MMM-yyyy') [ValidTo]
	,CASE WHEN v.RedeemOn IS NOT NULL THEN 'Redeemed' 
		WHEN (GETDATE() BETWEEN v.ValidFrom AND v.ValidTo) AND v.RedeemOn IS NULL THEN 'Active'
		ELSE 'Expired' END [Status]
	,l.LocationCode [Location]
	FROM [guest].[Voucher] v
	INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
	INNER JOIN guest.Guest g ON v.GuestID = g.GuestID
	INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
	INNER JOIN person.Title t ON cd.TitleID = t.TitleID
	INNER JOIN currency.Currency c ON v.CurrencyID = c.CurrencyID
	WHERE v.VoucherID = @VoucherID
END

