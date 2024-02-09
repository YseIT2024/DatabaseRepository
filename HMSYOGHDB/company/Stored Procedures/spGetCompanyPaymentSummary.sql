
CREATE PROCEDURE [company].[spGetCompanyPaymentSummary]-- 1,'2020-10-24', '2020-11-23',1
(
	@DrawerID int,
	@FromDate date,
	@ToDate date,
	@UserID int = null
)
AS
BEGIN
	DECLARE @LocationID int = (Select LocationID From app.Drawer Where DrawerID = @DrawerID);
	DECLARE @AccountTypeID int = 22; --Hotel Bill Paid By Casino

	SELECT t.CompanyID
	,cc.CompanyName
	,(l.LocationCode + CAST(re.FolioNumber as varchar(20))) FolioNumber	
	,ISNULL(pt.Title + ' ','') + cd.FirstName + ISNULL(' ' + cd.LastName,'') GuestName
	,c.CurrencySymbol + CAST(CAST(t.Amount as decimal(18,2)) as varchar(12)) Amount	
	,FORMAT(t.TransactionDateTime,'dd-MMM-yyyy hh:mm tt') [TransactionDate]
	,ISNULL(pt2.Title + ' ','') + cd2.FirstName + ISNULL(' ' + cd2.LastName,'') TransactionBy
	FROM [Account].[Transaction] t
	INNER JOIN [reservation].[Reservation] re ON t.ReservationID = re.ReservationID	AND t.CompanyID > 0
	INNER JOIN general.[Location] l ON re.LocationID = l.LocationID 
	INNER JOIN currency.Currency c ON t.CurrencyID = c.CurrencyID	
	INNER JOIN company.Company cc ON t.CompanyID = cc.CompanyID
	INNER JOIN guest.Guest g ON re.GuestID = g.GuestID
	INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
	INNER JOIN account.[Transaction] act ON t.TransactionID = act.TransactionID 
	INNER JOIN app.[User] u ON act.UserID = u.UserID 
	INNER JOIN contact.Details cd2 ON u.ContactID = cd2.ContactID
	LEFT JOIN person.Title pt On cd.TitleID = pt.TitleID
	LEFT JOIN person.Title pt2 On cd2.TitleID = pt2.TitleID	
	WHERE t.AccountTypeID = @AccountTypeID AND t.TransactionID IS NOT NULL AND CAST(t.TransactionDateTime as date) BETWEEN @FromDate AND @ToDate
	AND re.LocationID = @LocationID AND re.CompanyID > 0 AND re.ReservationStatusID IN (3,4)
	ORDER BY cc.CompanyName

	---Total pending balance currency
	SELECT CurrencyID, CurrencyCode
	FROM currency.Currency
	WHERE CurrencyID = 3

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Company Payment Summary', @UserID
END

