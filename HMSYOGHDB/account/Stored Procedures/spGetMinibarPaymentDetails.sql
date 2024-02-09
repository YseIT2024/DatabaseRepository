CREATE PROCEDURE [account].[spGetMinibarPaymentDetails] --8605
(
    @TransactionID int,
	@DrawerID int=0,
	@AccountingDateID int=0,
	@ReferenceNo int=0
)
AS
BEGIN
	SET NOCOUNT ON;
	IF EXISTS (SELECT TransactionID FROM account.[Transaction]  WHERE TransactionID = @TransactionID)
	BEGIN
	SELECT  Amount,TransactionID,ReservationID,ReportFooter='This is proof of your transaction. It cannot be used to claim Tax. Please note this is not an Invoice A valid Invoice for Tax purpose can only be issued by the property '
	FROM account.[Transaction] 
	where TransactionID =@TransactionID
	END
	ELSE
	BEGIN
	SELECT  Amount,TransactionID,ReservationID,ReportFooter='This is proof of your transaction. It cannot be used to claim Tax. Please note this is not an Invoice A valid Invoice for Tax purpose can only be issued by the property '
	FROM account.[VoidTransaction]
	where TransactionID =@TransactionID
	END
	
	IF EXISTS(Select TransactionID from account.[VoidTransaction] where TransactionID=@TransactionID)
	BEGIN
	SELECT 
	FORMAT(CAST(atm.ActualAmount AS DECIMAL(18, 6)), 'N2') AS PaidAmount,
     atm.ActualCurrencyID AS CurrencyID, 
    atm.TransactionModeID AS PaymentTypeID, 
	tm.TransactionMode,
	c.currencycode,
	--Case When 
	--At.AccountTypeID=95 
	--then
	--CONCAT(att.TransactionType, ' ', c.CurrencySymbol, ' ', FORMAT(atm.ActualAmount, 'N2'),'Minibar Payment')
	--When At.AccountTypeID=96
	--then
	--CONCAT(att.TransactionType, ' ', c.CurrencySymbol, ' ', FORMAT(atm.ActualAmount, 'N2'),'AddOn Item Payment')
	--End AS Description,
	At.Remarks as Description,
	ISNULL(FORMAT(atm.ExchangeRate,'N2'),0.00)as Rate,
	FORMAT(atm.Amount,'N2') AS USD
     FROM 
    account.[VoidTransaction] atm
    INNER JOIN account.TransactionType att ON atm.TransactionTypeID = att.TransactionTypeID
	INNER JOIN account.TransactionMode tm ON atm.TransactionModeID = tm.TransactionModeID 
    INNER JOIN currency.Currency c ON atm.ActualCurrencyID = c.CurrencyID
	Join account.[Transaction]  At On At.TransactionID=atm.TransactionID
    WHERE 
    atm.TransactionID = @TransactionID;	
	END
	
	IF EXISTS (SELECT TransactionID FROM [account].[TransactionSummary] WHERE TransactionID = @TransactionID)
	BEGIN
	SELECT 
	FORMAT(CAST(atm.Amount AS DECIMAL(18, 6)), 'N2') AS PaidAmount,
    atm.CurrencyID, 
    atm.PaymentTypeID, 
	tm.TransactionMode,
	c.currencycode,
	--Case When 
	--At.AccountTypeID=95 
	--then
	--CONCAT(att.TransactionType, ' ', c.CurrencySymbol, ' ', FORMAT(atm.Amount, 'N2'),'Minibar Payment')
	--When At.AccountTypeID=96
	--then
	--CONCAT(att.TransactionType, ' ', c.CurrencySymbol, ' ', FORMAT(atm.Amount, 'N2'),'AddOn Item Payment')
	--End AS Description,
	At.Remarks as Description,
	ISNULL(FORMAT(atm.Rate,'N2'),0.00)as Rate,
	FORMAT(ROUND(atm.Amount / ISNULL(atm.Rate, 1), 4), 'N2') AS USD
     FROM 
    [account].[TransactionSummary] atm
    INNER JOIN account.TransactionType att ON atm.TransactionTypeID = att.TransactionTypeID
	INNER JOIN account.TransactionMode tm ON atm.PaymentTypeID = tm.TransactionModeID 
    INNER JOIN currency.Currency c ON atm.CurrencyID = c.CurrencyID
	Join account.[Transaction]  At On At.TransactionID=atm.TransactionID
    WHERE 
    atm.TransactionID = @TransactionID;	
	END
ELSE
	BEGIN
	SELECT 
	FORMAT(CAST(atm.ActualAmount AS DECIMAL(18, 6)), 'N2') AS PaidAmount,
    atm.ActualCurrencyID AS CurrencyID, 
    atm.TransactionModeID As PaymentTypeID,
	tm.TransactionMode,
	c.currencycode,
	--CONCAT(att.TransactionType, ' ', c.CurrencySymbol, ' ', FORMAT(atm.ActualAmount, 'N2'), ' CASH') AS Description,
	atm.Remarks as Description,
	ISNULL(FORMAT(atm.ExchangeRate,'N2'),0.00)as Rate,
	FORMAT(atm.Amount,'N2') AS USD
     FROM account.[Transaction]  atm
    INNER JOIN account.TransactionType att ON atm.TransactionTypeID = att.TransactionTypeID
	INNER JOIN account.TransactionMode tm ON atm.TransactionModeID = tm.TransactionModeID 
    INNER JOIN currency.Currency c ON atm.ActualCurrencyID = c.CurrencyID
    WHERE 
    atm.TransactionID = @TransactionID;	
	END
END
