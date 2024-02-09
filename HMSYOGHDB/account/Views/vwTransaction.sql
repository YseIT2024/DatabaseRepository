


CREATE VIEW [account].[vwTransaction]
As
	SELECT TransactionID, t.TransactionTypeID, tt.TransactionType, tt.TransactionFactor, t.AccountTypeID, act.AccountType, LocationID,DrawerID, 
	ReservationID, Amount, t.CurrencyID, c.CurrencyCode, ActualAmount, ActualCurrencyID, actualC.CurrencyCode [ActualCurrencyCode], ExchangeRate, 
	Remarks, t.TransactionModeID, tm.TransactionMode, t.UserID, t.TransactionDateTime, t.AccountingDateID, t.ContactID,
	ISNULL(pt.Title + ' ','') + d.FirstName + ISNULL(' ' + d.LastName,'') [EnteredBy],t.ReferenceNo,
	case when GuestCompanyTypeId=1 then (select top(1) d.FirstName from guest.Guest g inner join contact.Details d on g.ContactID = d.ContactID where g.GuestID=t.GuestCompanyId)
	when GuestCompanyTypeId>1 then (select top(1)CompanyName from  guest.GuestCompany where CompanyID=t.GuestCompanyId) else '' end as PaymentBy
	FROM account.[Transaction] t   
	INNER JOIN account.AccountType act ON t.AccountTypeID = act.AccountTypeID
	INNER JOIN account.TransactionMode tm ON t.TransactionModeID = tm.TransactionModeID 
	INNER JOIN account.TransactionType tt ON t.TransactionTypeID = tt.TransactionTypeID
	INNER JOIN currency.Currency c ON t.CurrencyID = c.CurrencyID 
	INNER JOIN currency.Currency actualC ON t.ActualCurrencyID = actualC.CurrencyID
	INNER JOIN app.[User] u ON t.UserID = u.UserID 
	INNER JOIN contact.Details d ON u.ContactID = d.ContactID
	LEFT JOIN person.Title pt On d.TitleID = pt.TitleID
	--where t.statusid<>0
	
 

