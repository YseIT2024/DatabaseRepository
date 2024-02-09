
CREATE PROCEDURE [currency].[spGetExchangeRateHistoryCurrency]
(
	@DrawerID INT 
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT DISTINCT er.CurrencyID, CurrencyCode
	FROM [currency].Currency c 
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID 
	WHERE IsMain = 0 AND er.DrawerID =  @DrawerID	
END

