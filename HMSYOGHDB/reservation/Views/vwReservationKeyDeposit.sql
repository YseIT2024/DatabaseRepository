



CREATE VIEW [reservation].[vwReservationKeyDeposit]
AS
	SELECT gw.ReservationID, r.GuestID, SUM(gw.Amount) KeyDeposit, 1 [CurrencyID], SUM(gw.Amount) [KeyDepositInEuro]
	FROM guest.GuestWallet gw 
	INNER JOIN reservation.Reservation r ON gw.ReservationID = r.ReservationID
	WHERE gw.AccountTypeID IN (7,50)
	GROUP BY gw.ReservationID, r.GuestID











