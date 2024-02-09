CREATE PROCEDURE [account].[spGetTransactionDetails] --1,4768
(
	@DrawerID int,
	@AccountingDateID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT vwt.TransactionID
	,AccountType
	,CASE WHEN TransactionFactor = 1 THEN vwt.Amount ELSE 0 END [REC]
	,CASE WHEN TransactionFactor = -1 THEN ABS(vwt.Amount) ELSE 0 END [PAY]
	,Remarks
	,TransactionMode
	,EnteredBy
	,CASE WHEN vwt.ReservationID IS NULL THEN '' ELSE CAST(vwt.ReservationID as varchar(15)) END [ReservationID],
	
	--,cd.FirstName + CASE WHEN cd.LastName IS NULL THEN '' ELSE ' '+ cd.LastName END [Person]
	 COALESCE(
        (
            SELECT ISNULL(t.Title + ' ', '') + d.FirstName + ISNULL(' ' + d.LastName, '')
            FROM reservation.Reservation r 
            INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
            INNER JOIN contact.Details d ON g.ContactID = d.ContactID
			--INNER JOIN [general].[Employee] ge ON d.ContactID=ge.ContactID
            INNER JOIN person.Title t ON d.TitleID = t.TitleID
			
            WHERE r.ReservationID = vwt.ReservationID
        ),
        'UNKNOWN'
     ) AS Person
		
	,FORMAT(ad.AccountingDate,'dd-MMM-yyyy') [AccountingDate]
	,vwt.ActualCurrencyCode
	,ABS(vwt.ActualAmount) [ActualAmount]
	,vwt.ExchangeRate
	,TransactionType	
	,vwt.TransactionTypeID
	,TransactionFactor
	,CAST(0 as bit) IsVoid	
	,vwt.AccountTypeID	
	--,TS.Amount As PaidAmount
	--,TS.CurrencyID
	--,CC.CurrencyCode
	,PaymentBy
	FROM [account].[vwTransaction] vwt
	--INNER JOIN [account].[TransactionSummary] TS ON vwt.TransactionID=TS.TransactionID
	--INNER JOIN currency.Currency CC On TS.CurrencyID=CC.CurrencyID
	INNER JOIN account.AccountingDates ad ON vwt.AccountingDateID = ad.AccountingDateId		
	INNER JOIN contact.Details cd ON vwt.ContactID = cd.ContactID	
	WHERE vwt.DrawerID = @DrawerID AND vwt.AccountingDateID = @AccountingDateID
	ORDER BY vwt.TransactionID DESC
	
END
