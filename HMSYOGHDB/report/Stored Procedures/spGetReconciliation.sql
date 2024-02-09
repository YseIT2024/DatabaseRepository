
CREATE PROCEDURE [report].[spGetReconciliation] --'2019-12-06',1
(
	@AccountingDate DATE,
	@DrawerID INT
)
AS
BEGIN
	DECLARE @AccountingDateID INT = (SELECT AccountingDateId FROM account.AccountingDates WHERE AccountingDate = @AccountingDate AND DrawerID = @DrawerID)

	DECLARE @CashFigures TABLE (ID INT IDENTITY(1,1),DenominationTypeCode VARCHAR(50), OpeningQuantity DECIMAL(18,2) , USDOpeningValue DECIMAL(18,2),                                  
	ClosingQuantity DECIMAL(18,2), ClosingValue DECIMAL(18,2),MovementQuantity DECIMAL(18,2) ,MovementValue DECIMAL(18,2), BD DATE )                                  
	
	DECLARE @Account TABLE(AccountType VARCHAR(50), OpeningAmount DECIMAL(18,2),ClosingValue DECIMAL(18,4),Net DECIMAL(18,2),AccountTypeId INT)    
	DECLARE @Transaction TABLE(AccountType VARCHAR(50), OpeningAmount DECIMAL(18,2),ClosingValue DECIMAL(18,4),Net DECIMAL(18,2),AccountTypeId INT)             			                                             

	INSERT INTO  @CashFigures 
	(DenominationTypeCode, OpeningQuantity, USDOpeningValue, ClosingQuantity, ClosingValue, MovementQuantity, MovementValue)	
	Select  * FROM [report].[fnCashFigureValues] (@AccountingDate, @DrawerID)                      
                                                                    
	INSERT INTO @Account 
	(AccountType, OpeningAmount, ClosingValue, Net, AccountTypeId)                                  
	SELECT  '1110 Cash On Hand', SUM(USDOpeningValue), SUM(ClosingValue), ((SUM(ClosingValue)) - (SUM(USDOpeningValue))), 0 
	FROM @CashFigures 

	INSERT INTO @Transaction 
	(AccountType, OpeningAmount, ClosingValue, Net, AccountTypeId)                  
	SELECT CONVERT(VARCHAR(10),at.AccountNumber) + ' ' + vwt.AccountType 
	,CASE WHEN TransactionFactor = -1 THEN ABS(Amount) ELSE 0 END [PAY]
	,CASE WHEN TransactionFactor = 1 THEN Amount ELSE 0 END [REC]
	,(CASE WHEN TransactionFactor = 1 THEN Amount ELSE 0 END) - (CASE WHEN TransactionFactor = -1 THEN ABS(Amount) ELSE 0 END)
	,vwt.AccountTypeID
	FROM [account].[vwTransaction] vwt		
	INNER JOIN account.AccountingDates ad ON vwt.AccountingDateID = ad.AccountingDateId		
	INNER JOIN contact.Details cd ON vwt.ContactID = cd.ContactID
	INNER JOIN account.AccountType at ON vwt.AccountTypeID = at.AccountTypeID
	INNER JOIN account.AccountGroup ag ON at.AccountGroupID = ag.AccountGroupID	
	WHERE vwt.DrawerID = @DrawerID AND vwt.AccountingDateID = @AccountingDateID

	SELECT AccountTypeId, AccountType, (CASE WHEN Net > 0 THEN Net ELSE 0.00 END) [Debit(Pay)],
	(CASE WHEN Net < 0 THEN Net ELSE 0.00 END) [Credit(Rec)], (CASE WHEN Net > 0 THEN Net * (-1) ELSE Net END) Net
	FROM @Account

	UNION

	SELECT AccountTypeId, AccountType, ISNULL(SUM(OpeningAmount),0.00) [Debit(Pay)], ISNULL(SUM(ClosingValue),0.00) [Credit(Rec)], ISNULL(SUM(Net),0.00) Net 
	FROM @Transaction
	GROUP BY AccountType, AccountTypeId, Net
	HAVING Net <> 0.00
	ORDER BY AccountTypeId
END

