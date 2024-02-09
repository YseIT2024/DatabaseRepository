
CREATE PROCEDURE [guest].[spGetGuestVoucherDetails]
(	
	@Key int,
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

	IF(@Key = 1)----------Active Voucher------------------
		BEGIN
			SELECT [VoucherID]
			,r.LocationID
			,[VoucherNumber]			
			,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
			,t.Title + ' ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') [GuestName]
			,c.CurrencySymbol + CAST(CAST([Amount] as decimal(18,2)) as varchar(12)) [Amount]			
			,CAST(DATEDIFF(DAY, GETDATE(), ValidTo) as varchar(3)) + ' day(s) remaining.' [Valid]
			,FORMAT([ValidFrom],'dd-MMM-yyyy') [ValidFrom]
			,FORMAT([ValidTo],'dd-MMM-yyyy') [ValidTo]
			,'Active' [Status]
			,l.LocationName [Location]
			FROM [guest].[Voucher] v
			INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
			INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
			INNER JOIN guest.Guest g ON v.GuestID = g.GuestID
			INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
			INNER JOIN person.Title t ON cd.TitleID = t.TitleID
			INNER JOIN currency.Currency c ON v.CurrencyID = c.CurrencyID
			WHERE (GETDATE() BETWEEN v.ValidFrom AND v.ValidTo) AND v.RedeemOn IS NULL
			ORDER BY [VoucherID] DESC
		END
	ELSE IF(@Key = 2) --------Redeemed Voucher------------
		BEGIN
			SELECT [VoucherID]
			,r.LocationID
			,[VoucherNumber]			
			,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
			,t.Title + ' ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') [GuestName]
			,c.CurrencySymbol + CAST(CAST([Amount] as decimal(18,2)) as varchar(12)) [Amount]			
			,'' [Valid]
			,FORMAT([ValidFrom],'dd-MMM-yyyy') [ValidFrom]
			,FORMAT([ValidTo],'dd-MMM-yyyy') [ValidTo]
			,'Redeemed' [Status]
			,l.LocationName [Location]
			FROM [guest].[Voucher] v
			INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
			INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
			INNER JOIN guest.Guest g ON v.GuestID = g.GuestID
			INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
			INNER JOIN person.Title t ON cd.TitleID = t.TitleID
			INNER JOIN currency.Currency c ON v.CurrencyID = c.CurrencyID
			WHERE v.RedeemOn IS NOT NULL
			ORDER BY [VoucherID] DESC
		END
	ELSE IF(@Key = 3)--------Expired Voucher----------------
		BEGIN
			SELECT [VoucherID]
			,r.LocationID
			,[VoucherNumber]			
			,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
			,t.Title + ' ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') [GuestName]
			,c.CurrencySymbol + CAST(CAST([Amount] as decimal(18,2)) as varchar(12)) [Amount]			
			,'' [Valid]
			,FORMAT([ValidFrom],'dd-MMM-yyyy') [ValidFrom]
			,FORMAT([ValidTo],'dd-MMM-yyyy') [ValidTo]
			,'Expired' [Status]
			,l.LocationName [Location]
			FROM [guest].[Voucher] v
			INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
			INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
			INNER JOIN guest.Guest g ON v.GuestID = g.GuestID
			INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
			INNER JOIN person.Title t ON cd.TitleID = t.TitleID
			INNER JOIN currency.Currency c ON v.CurrencyID = c.CurrencyID
			WHERE GETDATE() > v.ValidTo AND v.RedeemOn IS NULL
			ORDER BY [VoucherID] DESC
		END

		-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Guest Voucher Details', @UserID
END

