
CREATE PROCEDURE [reservation].[spGetTotalOutstandingBalance] --1,'2020-06-03', '2020-07-03'
(
	@DrawerID int,
	@FromDate date = null,
	@ToDate date = null,
	@LocationID int = null,
	@UserID int = null
)
AS
BEGIN	
	DECLARE @Temp TABLE(ReservationID int, Amount decimal(18,2), Paid decimal(18,2), Balance decimal(18,2), EuroBalance decimal(18,2));

	INSERT intO @Temp(ReservationID, Amount, Paid, Balance, EuroBalance)
	SELECT DISTINCT re.ReservationID
	,CAST(fn.PayableAmount as decimal(18,2))
	,CAST(fn.TotalPayment as decimal(18,2))
	,CAST(fn.Balance as decimal(18,2))
	,CAST((fn.Balance/curRate.ExchangeRate) * eurRate.ExchangeRate as decimal(18,2))		
	FROM [reservation].[Reservation] re	
	INNER JOIN [reservation].[ReservedRoom] rm ON re.ReservationID = rm.ReservationID
	INNER JOIN [currency].[vwCurrentExchangeRate] curRate ON rm.RateCurrencyID = curRate.CurrencyID AND curRate.DrawerID = @DrawerID
	INNER JOIN [currency].[vwCurrentExchangeRate] eurRate ON eurRate.CurrencyID = 3 AND eurRate.DrawerID = @DrawerID
	CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](re.ReservationID)) fn
	WHERE re.LocationID = @LocationID AND re.ReservationStatusID IN (3,4)

	SELECT
	CASE WHEN rd.CompanyID > 0 THEN 'Company - ' + com.CompanyName ELSE 'Guest - ' + rd.FullName +' (' + CAST(rd.GuestID as varchar(10)) + ')' END [CompanyAndGuest]
	,rd.FolioNumber
	,[ReservationStatus]
	,c.CurrencySymbol + CAST(t.Amount as varchar(12)) Amount
	,c.CurrencySymbol + CAST(t.Paid as varchar(12)) Paid
	,c.CurrencySymbol + CAST(t.Balance as varchar(12)) Balance
	,t.EuroBalance
	FROM @Temp t
	INNER JOIN [reservation].[vwReservationDetails] rd ON t.ReservationID = rd.ReservationID
	INNER JOIN currency.Currency c ON rd.RateCurrencyID = c.CurrencyID
	INNER JOIN company.Company com ON rd.CompanyID = com.CompanyID
	WHERE t.Balance > 0 AND rd.ReservationStatusID IN (3,4)

	---Total pending balance currency
	SELECT CurrencyID, CurrencyCode
	FROM currency.Currency
	WHERE CurrencyID = 3

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Total Outstanding Balance', @UserID
END

