
CREATE PROCEDURE [currency].[spGetExchangeRate]
(
	@DrawerID INT
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID
	,er.CurrencyID
	,c.CurrencyCode
	,CAST(CASE WHEN c.IsStrongerThanMainCurrency = 1 THEN  (1/NewRate) ELSE NewRate END AS DECIMAL(18,4)) [NewRate]
	FROM [currency].[Currency] c
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID AND er.DrawerID = @DrawerID
	Where DrawerID = @DrawerID AND er.IsActive = 1
	ORDER BY CurrencyCode DESC	
END

