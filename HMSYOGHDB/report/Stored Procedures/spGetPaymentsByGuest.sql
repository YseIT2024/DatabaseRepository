
CREATE PROCEDURE [report].[spGetPaymentsByGuest]
(	
	@LocationID int,
	@DrawerID int,
	@Date datetime,
	@UserID int
)
AS
BEGIN		
	DECLARE @PrintedOn VARCHAR(20) = Format(GETDATE(),'dd-MMM-yyyy hh:mm tt');
	DECLARE @AccountingDateID INT = (SELECT AccountingDateId FROM account.AccountingDates WHERE AccountingDate = CONVERT(date,@Date) AND DrawerID = @DrawerID);
	DECLARE @CountOfGuest INT = (SELECT COUNT(DISTINCT(GuestID)) FROM [account].[Transaction] t
	INNER JOIN reservation.Reservation r ON t.ReservationID = r.ReservationID 
	WHERE AccountingDateID = @AccountingDateID) 
		
	SELECT vwr.FullName [GuestName]
	,rm.RoomNo [RoomNo]
	,vwr.FolioNumber
	,act.AccountType [AccountType]
	,c.CurrencyCode [Currency]
	,CASE WHEN tt.TransactionFactor = -1 THEN ABS(CAST(t.ActualAmount as decimal(18,2))) ELSE 0 END [Debit]
	,CASE WHEN tt.TransactionFactor = 1 THEN CAST(t.ActualAmount as decimal(18,2)) ELSE 0 END [Credit]
	,FORMAT(t.TransactionDateTime, 'dd-MMM-yyyy hh:mm tt') [TransDateTime]
	FROM [reservation].[vwReservationDetails] vwr 
	INNER JOIN [reservation].[ReservedRoom] rr ON vwr.ReservationID = rr.ReservationID
	INNER JOIN [room].[Room] rm ON rr.RoomID = rm.RoomID
	INNER JOIN [account].[Transaction] t ON vwr.ReservationID = t.ReservationID
	INNER JOIN account.AccountType act ON t.AccountTypeID = act.AccountTypeID 
	INNER JOIN account.TransactionType tt ON t.TransactionTypeID = tt.TransactionTypeID	
	INNER JOIN currency.Currency c ON t.ActualCurrencyID = c.CurrencyID
	WHERE AccountingDateID = @AccountingDateID AND  vwr.LocationID = @LocationID
	ORDER BY [RoomNo]

	SELECT  @PrintedOn [PrintedOn], @CountOfGuest [Count]

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Payments By Guest', @UserID
END
