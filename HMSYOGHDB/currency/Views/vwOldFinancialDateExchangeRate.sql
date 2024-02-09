



CREATE VIEW [currency].[vwOldFinancialDateExchangeRate]
AS
	WITH ctc1
	AS
	(
		SELECT 
		MAX(drch.ID) ID
		,drch.[CurrencyID]
		,drch.AccountingDateID
		,drch.DrawerID	
		FROM currency.Currency c 
		INNER JOIN [currency].[DailyRateChangeHistory] drch ON c.CurrencyID = drch.CurrencyID	
		GROUP BY drch.[CurrencyID], drch.AccountingDateID, drch.DrawerID		
	)
	SELECT ctc1.ID, ctc1.CurrencyID, drch2.AccountingDateId, ctc1.DrawerID, drch2.Rate [ExchangeRate]
	FROM ctc1
	INNER JOIN [currency].[DailyRateChangeHistory] drch2 ON ctc1.ID = drch2.ID


