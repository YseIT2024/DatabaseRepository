



CREATE VIEW [currency].[vwCurrentExchangeRate]
AS
	SELECT 
	[LocationID]
	,c.[CurrencyID]
	,[ExchangeRateToCurrencyID]	
	,[NewRate] AS [ExchangeRate]	
	,c.IsMain		
	,erh.DrawerID
	FROM currency.Currency c 
	INNER JOIN [currency].[ExchangeRateHistory] erh ON c.CurrencyID = erh.CurrencyID
	WHERE IsActive = 1 













