
CREATE PROCEDURE [report].[spGetAccountTransaction]
(
	@AccountingDate DATE,
	@DrawerID INT
)
AS
BEGIN
	DECLARE @AccountingDateID INT 
	= (SELECT AccountingDateID FROM account.AccountingDates WHERE AccountingDate = @AccountingDate AND DrawerID = @DrawerID);

	DECLARE @Drawer VARCHAR(100) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID)
	DECLARE @Location VARCHAR(100) = (SELECT LocationCode FROM general.Location WHERE LocationID = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID))

	DECLARE @tbl_Transaction TABLE(TransactionID INT, ReservationID VARCHAR(100), LocationCode VARCHAR(100), Drawer VARCHAR(200), AccountGroupID INT, AccountGroup VARCHAR(250), AccountTypeID INT, AccountType VARCHAR(100),
	CurrencyCode VARCHAR(100), Amount DECIMAL(18,6), Received DECIMAL(18,6), Paid DECIMAL(18,6),	Net DECIMAL(18,6), TransactionMode VARCHAR(100), Remarks VARCHAR(MAX))

	INSERT INTO @tbl_Transaction
	(TransactionID, ReservationID, LocationCode, Drawer,AccountGroupID, AccountGroup, AccountTypeID, AccountType, CurrencyCode, Amount, 
	Received, Paid, Net, TransactionMode, Remarks)
	SELECT TransactionID
	,CASE WHEN vwt.ReservationID IS NULL THEN '' ELSE CAST(vwt.ReservationID as varchar(15)) END [ReservationID]
	,@Location
	,@Drawer
	,at.AccountGroupID
	,AccountGroup
	,vwt.AccountTypeID
	,CONVERT(VARCHAR(10),at.AccountNumber)+' '+ vwt.AccountType
	,vwt.ActualCurrencyCode
	,ABS(vwt.ActualAmount) [ActualAmount]
	,CASE WHEN TransactionFactor = 1 THEN Amount ELSE 0 END [REC]
	,CASE WHEN TransactionFactor = -1 THEN ABS(Amount) ELSE 0 END [PAY]
	,(CASE WHEN TransactionFactor = 1 THEN Amount ELSE 0 END) - (CASE WHEN TransactionFactor = -1 THEN ABS(Amount) ELSE 0 END)	
	,TransactionMode
	,Remarks	
	FROM [account].[vwTransaction] vwt		
	INNER JOIN account.AccountingDates ad ON vwt.AccountingDateID = ad.AccountingDateId		
	INNER JOIN contact.Details cd ON vwt.ContactID = cd.ContactID
	INNER JOIN account.AccountType at ON vwt.AccountTypeID = at.AccountTypeID
	INNER JOIN account.AccountGroup ag ON at.AccountGroupID = ag.AccountGroupID	
	WHERE vwt.DrawerID = @DrawerID AND vwt.AccountingDateID = @AccountingDateID

	SELECT TransactionID, ReservationID, LocationCode, Drawer, AccountGroupID, AccountGroup,AccountTypeID, AccountType, CurrencyCode, Amount, 
	Received, Paid, Net, TransactionMode, Remarks 
	FROM @tbl_Transaction 
	ORDER BY AccountGroupID, AccountTypeID, TransactionID
END
