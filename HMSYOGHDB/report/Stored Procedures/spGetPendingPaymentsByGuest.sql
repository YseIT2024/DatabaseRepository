
CREATE PROCEDURE [report].[spGetPendingPaymentsByGuest]
(
	@LocationID int,
	@GuestID int
)
AS
BEGIN
	DECLARE @DrawerID int = (SELECT TOP 1 DrawerID FROM app.Drawer WHERE IsActive = 1 AND LocationID = @LocationID);
	DECLARE @Balance TABLE(ReservationID INT, Amount DECIMAL(18,4), Paid DECIMAL(18,4), Balance DECIMAL(18,4));

	INSERT INTO @Balance(ReservationID, Amount, Paid, Balance)
	SELECT DISTINCT re.[ReservationID]		
	,CAST(fn.PayableAmount as decimal(18,2))
	,CAST(fn.TotalPayment as decimal(18,2))
	,CAST(fn.Balance as decimal(18,2))
	FROM [reservation].[Reservation] re	
	CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](re.ReservationID)) fn 	
	WHERE re.LocationID = @LocationID AND re.GuestID = @GuestID AND re.ReservationStatusID IN (3,4)
	AND fn.Balance > 0 AND re.CompanyID = 0

	SELECT
	re.GuestID
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) [GuestName]	
	,(l.LocationCode + CAST(re.FolioNumber as varchar(20))) [FolioNumber]
	,r.RoomNo [RoomNo]
	,c.CurrencySymbol + ' ' + CONVERT(VARCHAR,CAST(b.Amount as decimal(18,2))) [Amount]
	,c.CurrencySymbol + ' ' + CONVERT(VARCHAR,CAST(b.Paid as decimal(18,2))) [Paid]
	,c.CurrencySymbol + ' ' + CONVERT(VARCHAR,CAST(b.Balance as decimal(18,2))) [Balance]	
	,CAST(((b.Balance / actualRate.ExchangeRate) * eurRate.ExchangeRate) as decimal(18,2)) EuroBalance
	FROM @Balance b	
	INNER JOIN [reservation].[Reservation] re ON b.ReservationID = re.ReservationID
	INNER JOIN [reservation].[ReservedRoom] rm ON re.ReservationID = rm.ReservationID
	INNER JOIN [currency].[Currency] c ON rm.RateCurrencyID = c.CurrencyID
	INNER JOIN currency.vwCurrentExchangeRate actualRate ON c.CurrencyID = actualRate.CurrencyID AND actualRate.DrawerID = @DrawerID
	INNER JOIN general.[Location] l ON re.LocationID = l.LocationID
	INNER JOIN [guest].[Guest] g ON re.GuestID = g.GuestID
	INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID	
	INNER JOIN person.Title t ON d.TitleID = t.TitleID
	INNER JOIN [room].[Room] r ON rm.RoomID = r.RoomID	
	CROSS APPLY (SELECT ExchangeRate FROM [currency].[vwCurrentExchangeRate] WHERE CurrencyID = 3 AND DrawerID = @DrawerID) eurRate
    WHERE re.LocationID = @LocationID AND b.Balance > 0	AND re.GuestID = @GuestID AND re.ReservationStatusID IN (3,4)

	---Total pending balance currency
	SELECT CurrencyID, CurrencyCode
	FROM currency.Currency
	WHERE CurrencyID = 3	
END
