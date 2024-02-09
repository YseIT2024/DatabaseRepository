CREATE PROCEDURE [guest].[spGetGuestTransactionHistory]
(
	@GuestID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT [WalletID]	
	,att.AccountType
	,tt.TransactionType
	,c.CurrencyCode [Currency]
	,ISNULL(gw.Amount,0) [Amount]	
	,d.Drawer
	,l.LocationCode [Location]
	,FORMAT(ad.AccountingDate,'dd-MMM-yyyy') [AccountingDate]
	,FORMAT(gw.[TransactionDateTime],'dd-MMM-yyyy HH:mm') [TranDate]
	,gw.[Remarks]	
	FROM [guest].[GuestWallet] gw
	INNER JOIN [account].[AccountType] att ON gw.AccountTypeID = att.AccountTypeID
	INNER JOIN [account].[TransactionType] tt ON gw.TransactionTypeID = tt.TransactionTypeID
	INNER JOIN [account].[AccountingDates] ad ON gw.AccountingDateID = ad.AccountingDateId
	INNER JOIN [app].[Drawer] d ON ad.DrawerID = d.DrawerID
	INNER JOIN [general].[Location] l ON d.LocationID = l.LocationID
	INNER JOIN [currency].[Currency] c ON gw.RateCurrencyID = c.CurrencyID
	WHERE gw.GuestID = @GuestID
END









