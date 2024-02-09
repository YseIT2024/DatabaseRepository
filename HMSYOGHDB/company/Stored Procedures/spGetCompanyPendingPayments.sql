
CREATE PROCEDURE [company].[spGetCompanyPendingPayments] --1,1,1,'2022-01-01','2022-08-01'
(
	@DrawerID int,	
	@LocationID int,
	@UserID int,
	@FromDate date = NULL,
	@ToDate date = NULL
)
AS
BEGIN	
	--DECLARE @Temp TABLE(ReservationID int, CompanyID int, PayableAmount decimal(18,2), Paid decimal(18,2), Balance decimal(18,2), EuroBalance decimal(18,2));

	--INSERT intO @Temp
	--(ReservationID, CompanyID, PayableAmount, Paid, Balance, EuroBalance)
	--SELECT DISTINCT r.ReservationID, r.CompanyID
	--,CAST(fn.PayableAmount as decimal(18,2))
	--,CAST(fn.TotalPayment as decimal(18,2))
	--,CAST(fn.Balance as decimal(18,2))
	--,CAST((fn.Balance / curRate.ExchangeRate) * eurRate.ExchangeRate as decimal(18,2))	
	--FROM [reservation].[Reservation] r 
	--INNER JOIN [reservation].[ReservedRoom] rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
	--INNER JOIN [currency].[vwCurrentExchangeRate] curRate ON rr.RateCurrencyID = curRate.CurrencyID AND curRate.DrawerID = @DrawerID	
	--INNER JOIN [currency].[vwCurrentExchangeRate] eurRate ON eurRate.CurrencyID = 3 AND eurRate.DrawerID = @DrawerID
	--CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](r.ReservationID)) fn
	--WHERE fn.Balance > 0 AND r.LocationID = @LocationID AND r.CompanyID > 0 AND r.ReservationStatusID IN (3,4)

	--SELECT rd.CompanyID
	--,cc.CompanyName
	--,rd.FolioNumber
	--,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [GuestName]	
	--,[CountryName] as [GuestCountry]
	--,FORMAT(ISNULL([ActualCheckIn],[ExpectedCheckIn]),'dd-MMM-yyyy') [CheckIn]
	--,FORMAT(ISNULL([ActualCheckOut],[ExpectedCheckOut]),'dd-MMM-yyyy') [CheckOut]
	--,[ReservationStatus]	
	--,c.CurrencySymbol + CAST(t.PayableAmount as varchar(12)) PayableAmount
	--,c.CurrencySymbol + CAST(t.Paid as varchar(12)) Paid
	--,c.CurrencySymbol + CAST(t.Balance as varchar(12)) Balance
	--,t.EuroBalance
	--FROM [reservation].[vwReservationDetails] rd
	--INNER JOIN currency.Currency c ON rd.RateCurrencyID = c.CurrencyID
	--INNER JOIN @Temp t ON rd.ReservationID = t.ReservationID
	--INNER JOIN company.Company cc ON t.CompanyID = cc.CompanyID
	--WHERE rd.LocationID = @LocationID AND rd.CompanyID > 0 AND rd.ReservationStatusID IN (3,4)
	--ORDER BY cc.CompanyName

	
	
	DECLARE @temp_1 table (ReservationID int, TotalAmount1 decimal(18,4), Discount decimal(18,4))
	
	INSERT INTO @temp_1
	SELECT r.ReservationID, SUM(ISNULL(rat.Rate,0)) as TotalAmount, SUM(ISNULL(rat.Rate,0) * ISNULL(d.[Percentage],0) / 100) as [Discount]
	FROM reservation.Reservation r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID 
	INNER JOIN reservation.Discount d ON rat.DiscountID = d.DiscountID
	WHERE LocationID = @LocationID AND r.CompanyID > 0 AND rat.IsActive = 1 AND rat.IsVoid = 0 AND r.ReservationStatusID IN (3,4)
	GROUP BY r.ReservationID


	DECLARE @temp_2 table (ReservationID int, ServiceAmount decimal(18,4))
			
	INSERT INTO @temp_2
	SELECT r.ReservationID, ABS(SUM(ISNULL(gw.Amount,0))) as [ServiceAmount]
	FROM reservation.Reservation r
	LEFT JOIN guest.GuestWallet gw ON r.ReservationID = gw.ReservationID
	WHERE LocationID = @LocationID AND r.CompanyID > 0 AND  gw.AccountTypeID = 28 AND r.ReservationStatusID IN (3,4)
	GROUP BY r.ReservationID
	

	DECLARE @temp_3 table (ReservationID int, TotalAmount2 decimal(18,4))

	INSERT INTO @temp_3
	SELECT a.ReservationID, (ISNULL(TotalAmount1,0) + ISNULL(ServiceAmount,0)) as [TotalAmount2]
	FROM @temp_1 a
	LEFT JOIN @temp_2 b ON a.ReservationID = b.ReservationID
	

	DECLARE @temp_4 table (ReservationID int, VoidAmount decimal(18,4))
	
	INSERT INTO @temp_4
	SELECT r.ReservationID, SUM(ISNULL(rat.Rate,0)) as [VoidAmount]
	FROM reservation.Reservation r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID 
	INNER JOIN reservation.Discount d ON rat.DiscountID = d.DiscountID
	WHERE LocationID = @LocationID AND r.CompanyID > 0 AND rat.IsActive = 1 AND rat.IsVoid = 1 AND r.ReservationStatusID IN (3,4)
	GROUP BY r.ReservationID


	DECLARE @temp_5 table (ReservationID int, Complimentary decimal(18,4))

	INSERT INTO @temp_5
	SELECT r.ReservationID, SUM(ISNULL(gw.Amount,0)) as Complimentary
	FROM reservation.Reservation r
	LEFT JOIN guest.GuestWallet gw ON r.ReservationID = gw.ReservationID
	WHERE LocationID = @LocationID AND r.CompanyID > 0 AND gw.AccountTypeID = 20 AND r.ReservationStatusID IN (3,4)
	GROUP BY r.ReservationID


	DECLARE @temp_6 table (ReservationID int, PayableAmount decimal(18,4))

	INSERT INTO @temp_6
	SELECT a.ReservationID, (ISNULL(TotalAmount2,0) - ISNULL(Discount,0) - ISNULL(VoidAmount,0) - ISNULL(Complimentary,0)) as [PayableAmount]
	FROM @temp_1 a
	LEFT JOIN @temp_3 b ON a.ReservationID = b.ReservationID
	LEFT JOIN @temp_4 c ON a.ReservationID = c.ReservationID
	LEFT JOIN @temp_5 d ON a.ReservationID = d.ReservationID


	DECLARE @temp_7 table (ReservationID int, Advance decimal(18,4))

	INSERT INTO @temp_7
	SELECT r.ReservationID, SUM(ISNULL(gw.Amount,0)) as [Advance]
	FROM reservation.Reservation r
	LEFT JOIN guest.GuestWallet gw ON r.ReservationID = gw.ReservationID
	WHERE LocationID = @LocationID AND r.CompanyID > 0 AND gw.AccountTypeID = 23 AND r.ReservationStatusID IN (3,4)
	GROUP BY r.ReservationID


	DECLARE @temp_8 table (ReservationID int, OtherPayment decimal(18,4))

	INSERT INTO @temp_8
	SELECT r.ReservationID, SUM(ISNULL(gw.Amount,0)) as [OtherPayment]
	FROM reservation.Reservation r
	LEFT JOIN guest.GuestWallet gw ON r.ReservationID = gw.ReservationID
	WHERE LocationID = @LocationID AND r.CompanyID > 0 AND r.ReservationStatusID IN (3,4) AND gw.AccountTypeID NOT IN (7,12,14,20,23,28,50,82,83,84,85)
	GROUP BY r.ReservationID
	

	DECLARE @temp_9 table (ReservationID int, [TotalPayment] decimal(18,4))	

	INSERT INTO @temp_9
	SELECT r.ReservationID, (ISNULL(OtherPayment,0) + ISNULL(Advance,0)) as [TotalPayment]
	FROM reservation.Reservation r 
	LEFT JOIN @temp_7 a ON r.ReservationID = a.ReservationID
	LEFT JOIN @temp_8 b ON r.ReservationID = b.ReservationID
	WHERE LocationID = @LocationID AND r.CompanyID > 0 AND r.ReservationStatusID IN (3,4)
	
	
	DECLARE @temp_10 table (ReservationID int, [Balance] decimal(18,4))
	
	INSERT @temp_10
	SELECT a.ReservationID, (ISNULL(PayableAmount,0) - ISNULL(TotalPayment,0)) as [Balance]
	FROM @temp_6 a
	LEFT JOIN @temp_9 b ON a.ReservationID = b.ReservationID


	SELECT rd.CompanyID
	,cc.CompanyName
	,rd.FolioNumber
	,[Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [GuestName]	
	,[CountryName] as [GuestCountry]
	,FORMAT(ISNULL([ActualCheckIn],[ExpectedCheckIn]),'dd-MMM-yyyy') [CheckIn]
	,FORMAT(ISNULL([ActualCheckOut],[ExpectedCheckOut]),'dd-MMM-yyyy') [CheckOut]
	,[ReservationStatus]	
	,c.CurrencySymbol + CAST(t1.PayableAmount as varchar(12)) PayableAmount
	,c.CurrencySymbol + CAST(t1.TotalPayment as varchar(12)) Paid
	,c.CurrencySymbol + CAST(t1.Balance as varchar(12)) Balance
	, CAST((t1.Balance / curRate.ExchangeRate) * eurRate.ExchangeRate as decimal(18,2))	[EuroBalance]
	FROM [reservation].[vwReservationDetails] rd
	INNER JOIN currency.Currency c ON rd.RateCurrencyID = c.CurrencyID
	INNER JOIN [currency].[vwCurrentExchangeRate] curRate ON rd.RateCurrencyID = curRate.CurrencyID AND curRate.DrawerID = @DrawerID	
	INNER JOIN [currency].[vwCurrentExchangeRate] eurRate ON eurRate.CurrencyID = 3 AND eurRate.DrawerID = @DrawerID	
	INNER JOIN company.Company cc ON rd.CompanyID = cc.CompanyID	
	INNER JOIN
	(		
		SELECT DISTINCT a.ReservationID, 	
		SUM(ISNULL(PayableAmount,0)) PayableAmount, 	
		SUM(ISNULL(TotalPayment,0)) TotalPayment, 
		SUM(ISNULL(Balance,0)) Balance
		FROM @temp_1 a
		LEFT JOIN @temp_3 b ON a.ReservationID = b.ReservationID
		LEFT JOIN @temp_4 c ON a.ReservationID = c.ReservationID
		LEFT JOIN @temp_5 d ON a.ReservationID = d.ReservationID
		LEFT JOIN @temp_6 e ON a.ReservationID = e.ReservationID
		LEFT JOIN @temp_7 f ON a.ReservationID = f.ReservationID
		LEFT JOIN @temp_8 g ON a.ReservationID = g.ReservationID
		LEFT JOIN @temp_9 h ON a.ReservationID = h.ReservationID
		LEFT JOIN @temp_10 i ON a.ReservationID = i.ReservationID
		GROUP BY  a.ReservationID		
	)t1	ON rd.ReservationID = t1.ReservationID
	WHERE rd.LocationID = @LocationID AND rd.CompanyID > 0 AND rd.ReservationStatusID IN (3,4)
	ORDER BY cc.CompanyName

	------Total pending balance currency-----
	SELECT CurrencyID, CurrencyCode
	FROM currency.Currency
	WHERE CurrencyID = 3

	-----Insert in Log Table -------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Company Pending Payments', @UserID
END
