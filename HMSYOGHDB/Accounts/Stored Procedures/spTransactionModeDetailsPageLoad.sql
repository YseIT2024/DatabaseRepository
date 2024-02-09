

CREATE PROCEDURE [Accounts].[spTransactionModeDetailsPageLoad]
AS
BEGIN	
	

	

    SELECT 0 TransactionModeID, 'Select Transaction Mode' TransactionMode
	UNION
	SELECT TransactionModeID,TransactionMode
	FROM  account.TransactionMode

	SELECT c.CurrencyID, c.CurrencyCode
	,er.NewRate [CurrencyRateUSD]
	,er.IsStrongerThanMainCurrency
	FROM [currency].[Currency] c
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID
	WHERE er.IsActive = 1 AND er.DrawerID =1
END