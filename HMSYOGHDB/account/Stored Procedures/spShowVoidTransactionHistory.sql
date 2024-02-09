
CREATE PROCEDURE [account].[spShowVoidTransactionHistory]
(
	@DrawerID int,
	@FromDate date,
	@ToDate date
)
AS
BEGIN	
	
	SELECT TransactionID
	,vwt.AccountType
	,CASE WHEN TransactionFactor = 1 THEN Amount ELSE 0 END [REC]
	,CASE WHEN TransactionFactor = -1 THEN ABS(Amount) ELSE 0 END [PAY]
	,Remarks
	,TransactionMode
	,EnteredBy
	,CASE WHEN vwt.ReservationID IS NULL THEN '' ELSE CAST(vwt.ReservationID as varchar(15)) END [ReservationID]
	,cd.FirstName + CASE WHEN cd.LastName IS NULL THEN '' ELSE ' '+ cd.LastName END [Person]
	,FORMAT(ad.AccountingDate,'dd-MMM-yyyy') [AccountingDate]
	,vwt.ActualCurrencyCode
	,ABS(vwt.ActualAmount) [ActualAmount]
	,vwt.ExchangeRate
	,TransactionType
	,AccountGroup
	,MainAccountType MainAccount
	,vwt.Reason	
	,vwt.VoidBy		
	FROM [account].[vwVoidTransaction] vwt		
	INNER JOIN account.AccountingDates ad ON vwt.AccountingDateID = ad.AccountingDateId		
	INNER JOIN contact.Details cd ON vwt.ContactID = cd.ContactID	
	INNER JOIN account.AccountType at ON vwt.AccountTypeID = at.AccountTypeID
	INNER JOIN account.AccountGroup ag ON at.AccountGroupID = ag.AccountGroupID
	INNER JOIN account.MainAccountType mt ON AG.MainAccountTypeID = MT.MainAccountTypeID
	WHERE vwt.DrawerID = @DrawerID AND (ad.AccountingDate BETWEEN CONVERT(DATE,@FromDate) AND CONVERT(DATE,@ToDate))
	ORDER BY TransactionID DESC
END









