
CREATE Proc [general].[spGetCasinoRateCurrency]
(	
	@LocationID int
)
AS
BEGIN
	SELECT c.CurrencyID, c.CurrencyCode
	FROM general.[Location] l
	INNER JOIN currency.Currency c ON l.CasinoRateCurrencyID = c.CurrencyID
	WHERE l.LocationID = @LocationID

	SELECT CurrencyID, CurrencyCode
	FROM currency.Currency
END


