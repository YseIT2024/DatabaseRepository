
CREATE PROCEDURE [guest].[spGetGuestVoucherByID] --'120200528205320'
(	
	@VoucherNumber varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @VoucherStatusID  int = 0;

	IF EXISTS(SELECT VoucherID FROM [guest].[Voucher] WHERE VoucherNumber = @VoucherNumber AND GETDATE() BETWEEN ValidFrom AND ValidTo AND RedeemOn IS NULL)
		BEGIN
			SET @VoucherStatusID = 1;--Valid
		END
	ELSE IF EXISTS(SELECT VoucherID FROM [guest].[Voucher] WHERE VoucherNumber = @VoucherNumber AND RedeemOn IS NOT NULL)
		BEGIN
			SET @VoucherStatusID = 2;--Redeemed
		END
	ELSE IF EXISTS(SELECT VoucherID FROM [guest].[Voucher] WHERE VoucherNumber = @VoucherNumber AND GETDATE() NOT BETWEEN ValidFrom AND ValidTo AND RedeemOn IS NULL)
		BEGIN
			SET @VoucherStatusID = 3;--Expired
		END
	ELSE
		BEGIN
			SET @VoucherStatusID = 4;--Invalid
		END

	SELECT @VoucherStatusID [VoucherStatusID];

	SELECT [VoucherID]		
	,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
	,t.Title + ' ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') [GuestName]
	,c.CurrencySymbol + CAST(CAST([Amount] as decimal(18,2)) as varchar(12)) [CurrencyAmount]		
	,CAST([Amount] as decimal(18,2)) [Amount]
	,FORMAT([ValidFrom],'dd-MMM-yyyy') [ValidFrom]
	,FORMAT([ValidTo],'dd-MMM-yyyy') [ValidTo]
	,v.CurrencyID
	,l.LocationName [Location]
	FROM [guest].[Voucher] v
	INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
	INNER JOIN guest.Guest g ON v.GuestID = g.GuestID
	INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
	INNER JOIN person.Title t ON cd.TitleID = t.TitleID
	INNER JOIN currency.Currency c ON v.CurrencyID = c.CurrencyID
	WHERE v.VoucherNumber = @VoucherNumber AND RedeemLocationID IS NULL	
END

