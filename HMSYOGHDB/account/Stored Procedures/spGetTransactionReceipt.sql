
CREATE PROCEDURE [account].[spGetTransactionReceipt]
(
	@TransactionID int,	
	@ReservationID int = NULL,
	@DrawerID int = NULL
)
AS
BEGIN
	SELECT TransactionID, ISNULL(t.ReservationID,0) ReservationID, tt.TransactionType, act.AccountType, Amount, c.CurrencyCode
	,ActualAmount, actualC.CurrencyCode [ActualCurrencyCode], ExchangeRate, Remarks, tm.TransactionMode, ad.AccountingDate
	,(ISNULL(t1.Title,'') + ' ' + d1.FirstName + CASE WHEN d1.LastName IS NULL THEN '' ELSE ' ' + d1.LastName END) [TransactionBy]  
	,(ISNULL(t2.Title,'') + ' ' + d2.FirstName + CASE WHEN d2.LastName IS NULL THEN '' ELSE ' ' + d2.LastName END) [PayOrReceiveBy]  
	FROM account.[Transaction] t   
	INNER JOIN account.AccountType act ON t.AccountTypeID = act.AccountTypeID
	INNER JOIN account.TransactionMode tm ON t.TransactionModeID = tm.TransactionModeID 
	INNER JOIN account.TransactionType tt ON t.TransactionTypeID = tt.TransactionTypeID
	INNER JOIN account.AccountingDates ad ON t.AccountingDateID = ad.AccountingDateId
	INNER JOIN currency.Currency c ON t.CurrencyID = c.CurrencyID 
	INNER JOIN currency.Currency actualC ON t.ActualCurrencyID = actualC.CurrencyID
	INNER JOIN app.[User] u ON t.UserID = u.UserID 
	INNER JOIN contact.Details d1 ON u.ContactID = d1.ContactID
	INNER JOIN person.Title t1 ON d1.TitleID = t1.TitleID
	INNER JOIN contact.Details d2 ON t.ContactID = d2.ContactID
	INNER JOIN person.Title t2 ON d2.TitleID = t2.TitleID
	WHERE T.TransactionID = @TransactionID
END

