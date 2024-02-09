-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER DATE,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION  [report].[fnCashFigureValues]--('2019-12-02',1)
(
	@AccountingDate DATE,
	@DrawerID INT
)

RETURNS @Output TABLE 
(    
	DenominationTypeCode varchar(10),
	USDOpeningQuantity decimal(18,4),
	USDOpeningValue decimal(18,4),
	USDClosingQuantity decimal(18,4),
	USDClosingValue decimal(18,4),
	MovementQuantityUSD decimal(18,4),
	MovementValueUSD decimal(18,4)
	
)
AS
BEGIN
	
	DECLARE @TodayAccountingDateID INT
	DECLARE @PreviousAccountingDateID INT
	DECLARE @PreviousAccountingDate DATE
	DECLARE @DeclareDenominationValue DECIMAL(18,4)
	DECLARE @TodayDenominationQunatity INT
	DECLARE @TodayDenominationValue Decimal(18,4)

	DECLARE @CountTempTable INT
	DECLARE @IncrementId INT
	DECLARE @MomvementQuantityDiff INT
	DECLARE @MovementQuantity INT
	DECLARE @MovementValue DECIMAL(18,4)


	SET @TodayAccountingDateID = (SELECT AccountingDateID FROM account.AccountingDates WHERE AccountingDate = @AccountingDate AND DrawerID = @DrawerID)
	SET @PreviousAccountingDateID = (SELECT MAX(AccountingDateID) FROM account.AccountingDates WHERE AccountingDateId < @TodayAccountingDateID AND DrawerID = @DrawerID )
	SET @PreviousAccountingDate = (SELECT AccountingDate FROM account.AccountingDates WHERE AccountingDateID = @PreviousAccountingDateID)


	DECLARE @TempConolidationTable Table(ID INT Identity(1,1),DenominationValue DECIMAL(18,4) ,DenominationTypeCode Varchar(10), OpeningQuantity INT, OpeningValue DECIMAL(18,4),
	ClosingQuantity INT NULL, ClosingValue DECIMAL(18,4) NULL, OpneningValueInUSD DECIMAL(18,4),
	ClosingValueInUSD DECIMAL(18,4))
	
	DECLARE @ClosingQuantity INT
	DECLARE @ClosingValue DECIMAL(18,4) 
	DECLARE @ClosingValueInUSD DECIMAL(18,4)
	

	INSERT INTO @TempConolidationTable 
	(DenominationValue, DenominationTypeCode, OpeningQuantity, OpeningValue, OpneningValueInUSD, ClosingQuantity, ClosingValue, ClosingValueInUSD)			
	SELECT d.DenominationValue, dt.DenominationType, 0,0.00,0.00,ISNULL(dvs.DenomQuantity,0),ISNULL(dvs.DenomQuantity * d.DenominationValue,0.00) AS OpeningValue, 
	ISNULL(dvs.DenomQuantity * d.DenominationValue * rc.Rate,0.00) AS Expr1
	FROM currency.DailyRateChangeHistory rc  
	INNER JOIN 	currency.DenominationStatistics dvs 
	INNER JOIN	currency.Denomination d ON dvs.DenominationID = d.DenominationID 
	INNER JOIN	currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID ON rc.CurrencyID = dt.CurrencyID
	WHERE(dvs.DrawerID = @DrawerID) AND (dvs.AccountingDateID = @TodayAccountingDateID) AND 
	 rc.IsActive =1 AND    (rc.AccountingDateId = @TodayAccountingDateID ) AND rc.DrawerID = @DrawerID 
	ORDER BY d.DenominationTypeID

	

	INSERT INTO @TempConolidationTable 
	(DenominationValue, DenominationTypeCode, OpeningQuantity, OpeningValue, OpneningValueInUSD, ClosingQuantity, ClosingValue, ClosingValueInUSD)			
	SELECT   d.DenominationValue,dt.DenominationType,ISNULL(dvs.DenomQuantity,0),ISNULL(dvs.DenomQuantity * d.DenominationValue,0.00) AS OpeningValue, 
	ISNULL((dvs.DenomQuantity * d.DenominationValue) * rc.Rate,0.00),	ISNULL(@ClosingQuantity,0) AS Expr1,ISNULL( @ClosingValue,0.00) AS Expr2 , ISNULL(@ClosingValueInUSD,0.00) AS Expr3
	FROM currency.DailyRateChangeHistory rc 
	INNER JOIN 	currency.DenominationStatistics dvs 
	INNER JOIN	currency.Denomination d ON dvs.DenominationID = d.DenominationID 
	INNER JOIN	currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID ON rc.CurrencyID = dt.CurrencyID
	WHERE     (dvs.DrawerID = @DrawerID) AND (dvs.AccountingDateID = @PreviousAccountingDateID) AND 
	rc.IsActive =1 AND (rc.AccountingDateId = @PreviousAccountingDateID ) and rc.DrawerID = @DrawerID  
	ORDER BY d.DenominationTypeID                     
    
	--SELECT * FROM @TempConolidationTable
	                   
	DECLARE  @DenominationValue Table (DId INT identity (1,1), DenominationTypeCode Varchar(10),DenominationValue DECIMAL(18,4) , OpeningQuantity INT, OpeningValue DECIMAL(18,4),
	ClosingQuantity INT NULL, ClosingValue DECIMAL(18,4) NULL, OpneningValueInUSD DECIMAL(18,4),
	ClosingValueInUSD DECIMAL(18,4) , MovementQuantity INT , MovementValue DECIMAL(18,4)  )
	
	INSERT INTO  @DenominationValue
	(DenominationValue ,DenominationTypeCode , OpeningQuantity , OpeningValue , OpneningValueInUSD,ClosingQuantity , ClosingValue ,
	ClosingValueInUSD , MovementQuantity, MovementValue)                 
	SELECT  DenominationValue , DenominationTypeCode , SUM(OpeningQuantity ) AS OpeningQuantity ,SUM(OpeningValue) AS OpeningValue,SUM(OpneningValueInUSD) AS OpneningValueInUSD,
	SUM(ClosingQuantity) AS ClosingQuantity, SUM(ClosingValue) AS ClosingValue , SUM(ClosingValueInUSD) AS ClosingValueInUSD ,
	SUM(ClosingQuantity) - SUM(OpeningQuantity) AS MovementQuantity ,SUM(ClosingValue) - SUM(OpeningValue) AS MovementValue  FROM @TempConolidationTable
	GROUP BY DenominationValue , DenominationTypeCode 
 
	---SELECT * FROM @DenominationValue
--Order by DId  desc


/************************************************************/

	DECLARE @OpeningUSDTable table (DenominationTypeCode Varchar(50), USDOpeningQuantity DECIMAL(18,4) , USDOpeningValue DECIMAL(18,4) 
	,USDClosingQuantity DECIMAL(18,4), USDClosingValue DECIMAL(18,4)  ,MovementQuantityUSD DECIMAL(18,4), MovementValueUSD DECIMAL(18,4))
	


	INSERT INTO @OpeningUSDTable (DenominationTypeCode,USDOpeningQuantity, USDOpeningValue , USDClosingQuantity,USDClosingValue, MovementQuantityUSD, MovementValueUSD)
	Select DenominationTypeCode,SUM(OpeningValue),SUM(OpneningValueInUSD),SUM(ClosingValue), SUM(ClosingValueInUSD),SUM(ClosingValue)- SUM(OpeningValue),SUM(ClosingValueInUSD)-SUM(OpneningValueInUSD)
	from @DenominationValue   group by DenominationTypeCode 


	INSERT INTO @Output
	SELECT DenominationTypeCode,ISNULL(USDOpeningQuantity,0) USDOpeningQuantity, ISNULL(USDOpeningValue,0.00) USDOpeningValue , ISNULL(USDClosingQuantity,0) USDClosingQuantity, 
	ISNULL(USDClosingValue,0.00) USDClosingValue, ISNULL(MovementQuantityUSD,0) MovementQuantityUSD, ISNULL(MovementValueUSD,0.00) MovementValueUSD  FROM @OpeningUSDTable

	
	RETURN
END










