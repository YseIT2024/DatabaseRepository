

create FUNCTION [currency].[fnGetCurrencyExchangeRateMain]
(
	@DrawerID int,
	@CurrencyId int
)
RETURNS decimal(18,8)
AS
BEGIN
	Declare @CurrencyRateMain decimal(18,8) = 0.00
	Declare @AccountingDateId int
	Select @AccountingDateId = [account].[GetAccountingDateIsActive](@DrawerID)

	SELECT   @CurrencyRateMain=CAST(CASE WHEN c.IsStrongerThanMainCurrency=1 THEN  1/NewRate ELSE NewRate END AS DECIMAL(18,4)) 
	FROM [currency].[Currency] c
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID=er.CurrencyID AND er.IsActive=1
	Where LocationID=@DrawerID




	RETURN @CurrencyRateMain
END










