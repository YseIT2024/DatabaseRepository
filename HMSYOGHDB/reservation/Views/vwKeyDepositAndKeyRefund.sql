





CREATE VIEW [reservation].[vwKeyDepositAndKeyRefund]
AS
	SELECT ReservationID, GuestID
	,ABS(SUM(CASE WHEN AccountTypeID = 7 THEN ISNULL(Amount,0) ELSE 0 END)) [KeyRefund]
	,ABS(SUM(CASE WHEN AccountTypeID = 50 THEN ISNULL(Amount,0) ELSE 0 END)) [KeyDeposit]	
	FROM [guest].[GuestWallet]
	WHERE AccountTypeID IN (7,50)	
	GROUP BY ReservationID, GuestID






