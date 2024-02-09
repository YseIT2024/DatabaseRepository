
CREATE PROCEDURE [account].[spGetVoidTransactionDetails] --1,1295
(
	@DrawerID int,
	@AccountingDateID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT TransactionID
	,AccountType
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
	,TransactionFactor
	,CAST(1 as bit) IsVoid
	,vwt.Reason	
	,vwt.VoidBy		
	FROM [account].[vwVoidTransaction] vwt		
	INNER JOIN account.AccountingDates ad ON vwt.AccountingDateID = ad.AccountingDateId		
	INNER JOIN contact.Details cd ON vwt.ContactID = cd.ContactID	
	WHERE vwt.DrawerID = @DrawerID AND vwt.AccountingDateID = @AccountingDateID
	ORDER BY TransactionID DESC
END

