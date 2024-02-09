




CREATE VIEW [reservation].[vwReservationKeyDepositAndKeyRefund]
AS
	SELECT  
	gw.ReservationID
	,r.GuestID
	,CASE WHEN gw.AccountTypeID = 50 THEN SUM(gw.Amount) ELSE 0 END KeyDeposit
	,CASE WHEN gw.AccountTypeID = 7 THEN (-1) * SUM(gw.Amount) ELSE 0 END KeyRefund
	,1 [CurrencyID]
	,CASE WHEN gw.AccountTypeID = 50 THEN SUM(gw.Amount) ELSE 0 END [KeyDepositInEuro]
	,CASE WHEN gw.AccountTypeID = 7 THEN (-1) * SUM(gw.Amount) ELSE 0 END [KeyRefundInEuro]
	FROM guest.GuestWallet gw 
	INNER JOIN reservation.Reservation r ON gw.ReservationID = r.ReservationID
	WHERE gw.AccountTypeID IN (7,50)
	GROUP BY AccountTypeID, gw.ReservationID, r.GuestID










