
CREATE PROCEDURE [report].[spGetCashFigures] --'2019-12-02',1
(
	@AccountingDate DATE,
	@DrawerID INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TodayAccountingDateID INT = (SELECT AccountingDateID FROM account.AccountingDates WHERE DrawerID = @DrawerID AND AccountingDate = @AccountingDate)
	DECLARE @PreviousAccountingDateID INT = (SELECT MAX(AccountingDateID) FROM account.AccountingDates WHERE AccountingDateId < @TodayAccountingDateID AND DrawerID = @DrawerID )
	
	DECLARE @Temp TABLE (ID INT IDENTITY(1,1), CurrencyID INT, Currency VARCHAR(6), OpQuantity DECIMAL(25,2), OpUSDValue DECIMAL(25,2),
	ClQuantity DECIMAL(25,2), ClUSDValue DECIMAL(25,2), MovQuantity DECIMAL(25,2), MovUSDValue DECIMAL(25,2))
	
	INSERT INTO @Temp (CurrencyID,Currency) 
	SELECT CurrencyID,CurrencyCode  
	FROM Currency.Currency
	
	DECLARE @Count INT = (SELECT COUNT(*) FROM @Temp);
	DECLARE @Incr INT = 1;
	DECLARE @CurrencyID INT;
	DECLARE @Qty DECIMAL(25,2);
	DECLARE @USDValue DECIMAL(25,2);	
	
	WHILE(@Incr <= @Count)
	BEGIN
		SELECT @CurrencyID = CurrencyID FROM @Temp WHERE ID = @Incr;
		
		SELECT @Qty = ISNULL(SUM(DenomTotal),0.00), @USDValue = ISNULL(SUM(DenomTotalUSD),0.00)
		FROM currency.vwDenominationValue
		WHERE (AccountingDateId =  @PreviousAccountingDateID) AND (CurrencyID = @CurrencyID) AND (DenominationValueTypeID = 1)
		
		UPDATE @Temp 
		SET OpQuantity = @Qty
		,OpUSDValue = @USDValue 
		WHERE CurrencyID = @CurrencyID
		
		SELECT @Qty = ISNULL(SUM(DenomTotal),0.00), @USDValue = ISNULL(SUM(DenomTotalUSD),0.00)
		FROM currency.vwDenominationValue
		WHERE (AccountingDateId = @TodayAccountingDateID) AND (CurrencyID = @CurrencyID) AND (DenominationValueTypeID = 1)
		
		UPDATE @Temp 
		SET ClQuantity = @Qty
		,ClUSDValue = @USDValue 
		WHERE CurrencyID = @CurrencyID
				
		SET @Incr += 1
	END	
	
	UPDATE @Temp 
	SET MovQuantity = (ClQuantity - OpQuantity ) 
	,MovUSDValue = (ClUSDValue - OpUSDValue)	
	
	SELECT Currency, OpQuantity, OpUSDValue, ClQuantity, ClUSDValue, MovQuantity, MovUSDValue
	FROM @Temp
END

