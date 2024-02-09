
CREATE PROCEDURE [report].[spGetCurrencyRateOfCurrentDate]
(
	@AccountingDate DATE,
	@DrawerID INT
)
AS
BEGIN	
	DECLARE @AccountingDateID INT = 
		(SELECT MAX(AccountingDateID) FROM account.AccountingDates WHERE AccountingDate = @AccountingDate AND DrawerID = @DrawerID);
	
	SELECT DISTINCT c.CurrencyCode, Rate ExchangeRate 
	FROM currency.DailyRateChangeHistory rc
	INNER JOIN currency.Currency c ON rc.CurrencyID = c.CurrencyID
	WHERE IsActive = 1 AND AccountingDateId = @AccountingDateID AND DrawerID = @DrawerID
	ORDER BY c.CurrencyCode DESC
END



