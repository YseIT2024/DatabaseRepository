
CREATE PROCEDURE [report].[spGetCurrencyRateOfPreviousDate] --'01-FEB-2020',1
(
	@AccountingDate DATE,
	@DrawerID INT
)
AS
BEGIN	
	DECLARE @AccountingDateID INT = 
		(SELECT AccountingDateID FROM account.AccountingDates WHERE AccountingDate = @AccountingDate AND DrawerID = @DrawerID);

	DECLARE @PreviousAccountingDateID INT = 
		(SELECT MAX(AccountingDateID) FROM account.AccountingDates WHERE AccountingDateId < @AccountingDateID AND DrawerID = @DrawerID);
	
	SELECT DISTINCT c.CurrencyCode, Rate ExchangeRate
	FROM currency.DailyRateChangeHistory rc
	INNER JOIN currency.Currency c ON rc.CurrencyID = c.CurrencyID AND  rc.DrawerID = @DrawerID
	WHERE IsActive = 1 AND AccountingDateId = @PreviousAccountingDateID 
	ORDER BY c.CurrencyCode DESC
END
