





CREATE VIEW [account].[vwVoidTransaction]
As
	SELECT TransactionID, t.TransactionTypeID, tt.TransactionType, tt.TransactionFactor, t.AccountTypeID, act.AccountType, LocationID,DrawerID, 
	ReservationID, Amount, t.CurrencyID, c.CurrencyCode, ActualAmount, ActualCurrencyID, actualC.CurrencyCode [ActualCurrencyCode], ExchangeRate, 
	Remarks, t.TransactionModeID, tm.TransactionMode, t.UserID, t.TransactionDateTime, t.AccountingDateID, t.ContactID,
	ISNULL(pt.Title + ' ','') + d1.FirstName + ISNULL(' ' + d1.LastName,'') [EnteredBy], Reason,  ISNULL(pt.Title + ' ','') + d2.FirstName + ISNULL(' ' + d2.LastName,'') [VoidBy],
	FORMAT([DateTime], 'dd-MMM-yyyy hh:mm tt') [VoidOn]  
	FROM account.[VoidTransaction] t   
	INNER JOIN account.AccountType act ON t.AccountTypeID = act.AccountTypeID
	INNER JOIN account.TransactionMode tm ON t.TransactionModeID = tm.TransactionModeID 
	INNER JOIN account.TransactionType tt ON t.TransactionTypeID = tt.TransactionTypeID
	INNER JOIN currency.Currency c ON t.CurrencyID = c.CurrencyID 
	INNER JOIN currency.Currency actualC ON t.ActualCurrencyID = actualC.CurrencyID
	INNER JOIN app.[User] u1 ON t.UserID = u1.UserID	
	INNER JOIN contact.Details d1 ON u1.ContactID = d1.ContactID
	INNER JOIN app.[User] u2 ON t.VoidBy = u2.UserID	
	INNER JOIN contact.Details d2 ON u2.ContactID = d2.ContactID
	LEFT JOIN person.Title pt On d2.TitleID = pt.TitleID



