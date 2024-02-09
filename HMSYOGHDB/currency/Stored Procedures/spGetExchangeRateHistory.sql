
CREATE PROCEDURE [currency].[spGetExchangeRateHistory]
(
	@DrawerID int,
	@CurrencyID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	    
	SELECT ID
	,er.CurrencyID
	,c.CurrencyCode
	,[Description]
	,L.LocationCode
	,CAST(CASE WHEN er.IsStrongerThanMainCurrency = 1 THEN 1/OldRate ELSE OldRate END as decimal(18,4)) OldRate
	,CAST(CASE WHEN er.IsStrongerThanMainCurrency = 1 THEN 1/NewRate ELSE NewRate END as decimal(18,4)) NewRate
	,FORMAT(AccountingDate,'dd-MMM-yyyy') AccountingDate
	,FORMAT(RateChangeTime,'dd-MMM-yyyy HH:mm') RateChangeTime
	,CASE WHEN er.IsActive = 1 THEN 'Active' ELSE 'In-Active' END [Status]	
	,ISNULL(t.Title + ' ','') + cd.FirstName + ISNULL(' ' + cd.LastName,'') EnterBy
	FROM [currency].[Currency] c
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID
	INNER JOIN [general].[Location] l ON er.LocationID = l.LocationID
	INNER JOIN app.[User] u ON er.UserID = u.UserID
	LEFT JOIN contact.Details cd ON u.ContactID = cd.ContactID
	LEFT JOIN person.Title t ON cd.TitleID = t.TitleID
	WHERE er.DrawerID = @DrawerID AND er.CurrencyID = @CurrencyID
	ORDER BY ID DESC
END


