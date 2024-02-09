
CREATE PROCEDURE [guest].[spGetVoucherSummaryByGuest]
(	
	@DrawerID int = null,
	@UserID int = null
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LocationID INT = NULL;

	IF(@DrawerID IS NOT NULL)
		SET @LocationID = 
		(
			Select LocationID From app.Drawer Where DrawerID = @DrawerID
		);
	
	SELECT v.GuestID
	,t.Title + ' ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') [GuestName]
	,[VoucherNumber]			
	,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
	,CAST(CASE WHEN V.CurrencyID = 1 THEN [Amount] ELSE 0 END as decimal(18,2)) [MainCurrency]	
	,CAST(CASE WHEN V.CurrencyID = 2 THEN [Amount] ELSE 0 END as decimal(18,2)) [LocalCurrency]	
	,CAST(CASE WHEN V.CurrencyID = 3 THEN [Amount] ELSE 0 END as decimal(18,2)) [OtherCurrency1]		
	,CAST(DATEDIFF(DAY, ValidFrom, ValidTo) as varchar(3)) + ' day(s) remaining.' [Valid]	
	,l.LocationCode [Location]
	FROM [guest].[Voucher] v
	INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
	INNER JOIN guest.Guest g ON v.GuestID = g.GuestID
	INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
	INNER JOIN person.Title t ON cd.TitleID = t.TitleID
	WHERE (GETDATE() BETWEEN v.ValidFrom AND v.ValidTo) AND v.RedeemOn IS NULL	
	
	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Voucher Summary By Guest', @UserID	
END

