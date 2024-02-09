
CREATE PROCEDURE [guest].[spGetGuestWalletBalance]
(
	@GuestID int,
	@DrawerID int 
)
AS
BEGIN
	SET NOCOUNT ON;	
	
	SELECT c.CurrencyID
	,c.CurrencyCode [Currency]
	,CAST(SUM(CASE WHEN gw.WalletID IS NULL THEN 0 ELSE gw.Amount END) as decimal(18,2)) [Balance]
	FROM currency.Currency c
	LEFT JOIN [guest].[GuestWallet] gw ON c.CurrencyID = gw.RateCurrencyID AND gw.GuestID = @GuestID	
	GROUP BY c.CurrencyID, c.CurrencyCode	

	SELECT  ISNULL(CAST(SUM(Amount/c.ExchangeRate) as decimal(18,2)),0) [TotalBalance]
	FROM currency.vwCurrentExchangeRate c
	LEFT JOIN [guest].[GuestWallet] gw ON c.CurrencyID = gw.RateCurrencyID AND gw.GuestID = @GuestID
	WHERE c.DrawerID = @DrawerID
	

	
END









