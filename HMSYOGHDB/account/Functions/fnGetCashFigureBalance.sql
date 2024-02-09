
CREATE FUNCTION [account].[fnGetCashFigureBalance]
(
	@DrawerID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN	
	DECLARE @Balance DECIMAL(18,6);	
	DECLARE @AccountingDateId INT;
	DECLARE @PrevAccountingDateID INT;	
	DECLARE @PrevDayCash DECIMAL(18,6);	
	DECLARE @CurrentDayCash DECIMAL(18,6);
	DECLARE @CurrentDayTranTotal DECIMAL(18,6);
		
	SELECT @AccountingDateId = [Account].[GetAccountingDateIsActive](@DrawerID)

	SELECT @PrevAccountingDateID = MAX(AccountingDateId)
	FROM [account].[AccountingDates]
	WHERE IsActive = 0 AND DrawerID = @DrawerID	
		
	SELECT @PrevDayCash = ISNULL(CAST(Sum(ds.DenomTotalValue / vwc.ExchangeRate) AS DECIMAL(18,6)),0.00)
	FROM currency.DenominationStatistics ds 
	INNER JOIN currency.Denomination d ON ds.DenominationID = d.DenominationID
	INNER JOIN currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID 
	INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID 
	INNER JOIN [currency].[vwOldFinancialDateExchangeRate] vwc ON c.CurrencyID = vwc.CurrencyID AND vwc.DrawerID = @DrawerID AND vwc.AccountingDateId = @PrevAccountingDateID
	WHERE ds.AccountingDateId = @PrevAccountingDateID AND ds.DrawerID = @DrawerID		

	SELECT @CurrentDayCash = ISNULL(CAST(Sum(ds.DenomTotalValue / vwc.ExchangeRate) AS DECIMAL(18,6)),0.00)
	FROM currency.DenominationStatistics ds
	INNER JOIN currency.Denomination d ON ds.DenominationID = d.DenominationID
	INNER JOIN currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID 
	INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID 
	INNER JOIN [currency].[vwCurrentExchangeRate] vwc ON c.CurrencyID = vwc.CurrencyID  AND vwc.DrawerID = @DrawerID
	WHERE ds.AccountingDateId = @AccountingDateId AND ds.DrawerID = @DrawerID

	SELECT @CurrentDayTranTotal = ISNULL(CAST(SUM(Amount) AS DECIMAL(18,6)), 0.00)
	FROM [account].[Transaction]
	WHERE DrawerID = @DrawerID AND CurrencyId = 1 AND AccountingDateID = @AccountingDateId And AccountTypeID NOT IN (16)			

	SET @Balance = (@CurrentDayCash - @CurrentDayTranTotal) - @PrevDayCash;
	
	RETURN @Balance;
END


