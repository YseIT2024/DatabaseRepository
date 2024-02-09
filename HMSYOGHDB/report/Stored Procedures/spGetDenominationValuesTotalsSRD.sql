-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER DATE,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [report].[spGetDenominationValuesTotalsSRD] --'2019-12-02',1
(
	@AccountingDate DATE,
	@DrawerID INT
)
AS
BEGIN
	
	DECLARE @TodayAccountingDateID INT
	DECLARE @PreviousAccountingDateID INT
	DECLARE @PreviousAccountingDate DATE
	DECLARE @DeclareDenominationValue DECIMAL(18,2)
	DECLARE @TodayDenominationQunatity INT
	DECLARE @TodayDenominationValue Decimal(18,2)

	DECLARE @CountTempTable INT
	DECLARE @IncrementId INT
	DECLARE @MomvementQuantityDiff INT
	DECLARE @MovementQuantity INT
	DECLARE @MovementValue DECIMAL(18,2)


	SET @TodayAccountingDateID = (SELECT AccountingDateID FROM account.AccountingDates WHERE AccountingDate = @AccountingDate AND DrawerID = @DrawerID)
	SET @PreviousAccountingDateID = (SELECT MAX(AccountingDateID) FROM account.AccountingDates WHERE AccountingDateId < @TodayAccountingDateID AND DrawerID = @DrawerID )
	SET @PreviousAccountingDate = (SELECT AccountingDate FROM account.AccountingDates WHERE AccountingDateID = @PreviousAccountingDateID)


	DECLARE @TempConolidationTable Table(ID INT Identity(1,1),DenominationValue DECIMAL(18,2) ,DenominationTypeCode Varchar(10), OpeningQuantity INT, OpeningValue DECIMAL(18,2),
	ClosingQuantity INT NULL, ClosingValue DECIMAL(18,2) NULL, OpneningValueInUSD DECIMAL(18,2),
	ClosingValueInUSD DECIMAL(18,2))
	
	DECLARE @ClosingQuantity INT
	DECLARE @ClosingValue DECIMAL(18,2) 
	DECLARE @ClosingValueInUSD DECIMAL(18,2)
	

	INSERT INTO @TempConolidationTable 
	(DenominationValue, DenominationTypeCode, OpeningQuantity, OpeningValue, OpneningValueInUSD, ClosingQuantity, ClosingValue, ClosingValueInUSD)			
	SELECT d.DenominationValue, dt.DenominationType, 0,0.00,0.00,ISNULL(dvs.DenomQuantity,0),ISNULL(dvs.DenomQuantity * d.DenominationValue,0.00) AS OpeningValue, 
	ISNULL(dvs.DenomQuantity * d.DenominationValue / rc.Rate,0.00) AS Expr1
	FROM currency.DailyRateChangeHistory rc  
	INNER JOIN 	currency.DenominationStatistics dvs 
	INNER JOIN	currency.Denomination d ON dvs.DenominationID = d.DenominationID 
	INNER JOIN	currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID ON rc.CurrencyID = dt.CurrencyID
	WHERE(dvs.DrawerID = @DrawerID) AND (dvs.AccountingDateID = @TodayAccountingDateID) AND 
	 rc.IsActive =1 AND    (rc.AccountingDateId = @TodayAccountingDateID ) AND rc.DrawerID = @DrawerID AND dt.DenominationTypeID = 2
	ORDER BY d.DenominationTypeID

	

	INSERT INTO @TempConolidationTable 
	(DenominationValue, DenominationTypeCode, OpeningQuantity, OpeningValue, OpneningValueInUSD, ClosingQuantity, ClosingValue, ClosingValueInUSD)			
	SELECT   d.DenominationValue,dt.DenominationType,ISNULL(dvs.DenomQuantity,0),ISNULL(dvs.DenomQuantity * d.DenominationValue,0.00) AS OpeningValue, 
	ISNULL((dvs.DenomQuantity * d.DenominationValue) / rc.Rate,0.00),	ISNULL(@ClosingQuantity,0) AS Expr1,ISNULL( @ClosingValue,0.00) AS Expr2 , ISNULL(@ClosingValueInUSD,0.00) AS Expr3
	FROM currency.DailyRateChangeHistory rc 
	INNER JOIN 	currency.DenominationStatistics dvs 
	INNER JOIN	currency.Denomination d ON dvs.DenominationID = d.DenominationID 
	INNER JOIN	currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID ON rc.CurrencyID = dt.CurrencyID
	WHERE     (dvs.DrawerID = @DrawerID) AND (dvs.AccountingDateID = @PreviousAccountingDateID) AND 
	rc.IsActive =1 AND (rc.AccountingDateId = @PreviousAccountingDateID ) and rc.DrawerID = @DrawerID AND dt.DenominationTypeID = 2 
	ORDER BY d.DenominationTypeID                         
    
	--SELECT * FROM @TempConolidationTable
	                   
	DECLARE  @DenominationValue Table (DId INT identity (1,1), DenominationTypeCode Varchar(10),DenominationValue DECIMAL(18,2) , OpeningQuantity INT, OpeningValue DECIMAL(18,2),
	ClosingQuantity INT NULL, ClosingValue DECIMAL(18,2) NULL, OpneningValueInUSD DECIMAL(18,2),
	ClosingValueInUSD DECIMAL(18,2) , MovementQuantity INT , MovementValue DECIMAL(18,2)  )
	
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

	DECLARE @OpeningUSDTable table (ID INT identity(1,1),DenominationTypeCode Varchar(50), USDOpeningQuantity DECIMAL(18,2) , USDOpeningValue DECIMAL(18,2) , SRDOpeningQuantity DECIMAL(18,2), SRDOpeningValue DECIMAL(18,2), EuroOpeningQuantity DECIMAL(18,2) , EuroOpeningValue DECIMAL(18,2)
	,USDClosingQuantity DECIMAL(18,2), USDClosingValue DECIMAL(18,2) ,SRDClosingQuantity DECIMAL(18,2), SRDClosingValue DECIMAL(18,2) ,EuroClosingQuantity DECIMAL(18,2) ,EuroClosingValue DECIMAL(18,2) ,MovementQuantityUSD DECIMAL(18,2),MovementQuantitySRD DECIMAL(18,2),MovementQuantityEuro DECIMAL(18,2), MovementValueUSD DECIMAL(18,2) , MovementValueSRD DECIMAL(18,2) , MovementEuro DECIMAL(18,2))
	DECLARE @MovementValueUSD DECIMAL(18,2)
	DECLARE @MovementValueSRD DECIMAL(18,2)
	DECLARE @MovementValueEuro DECIMAL(18,2)
	DECLARE @MovementUSDQuantity DECIMAL(18,2)
	DECLARE @MovementSRDQuantity DECIMAL(18,2)
	DECLARE @MovementEuroQuantity DECIMAL(18,2)


	INSERT INTO @OpeningUSDTable (USDOpeningQuantity, USDOpeningValue , USDClosingQuantity,USDClosingValue)
	SELECT 
		(SELECT SUM(OpeningValue) FROM @DenominationValue)  ,
		(SELECT SUM(OpneningValueInUSD) FROM @DenominationValue)  , 
		(SELECT SUM(ClosingValue) FROM @DenominationValue)  ,
		(SELECT SUM(ClosingValueInUSD) FROM @DenominationValue)

	SET @MovementUSDQuantity = (SELECT SUM(ClosingValue) FROM @DenominationValue) - (SELECT SUM(OpeningValue) FROM @DenominationValue)
	SET @MovementValueUSD = (SELECT SUM(ClosingValueInUSD) FROM @DenominationValue) - (SELECT SUM(OpneningValueInUSD) FROM @DenominationValue)

	UPDATE @OpeningUSDTable SET DenominationTypeCode = 'SRD CASH',MovementValueUSD  = @MovementValueUSD , MovementQuantityUSD = @MovementUSDQuantity 

	SELECT DenominationTypeCode,ISNULL(USDOpeningQuantity,0) USDOpeningQuantity, ISNULL(USDOpeningValue,0.00) USDOpeningValue , ISNULL(USDClosingQuantity,0) USDClosingQuantity, 
	ISNULL(USDClosingValue,0.00) USDClosingValue, ISNULL(MovementQuantityUSD,0) MovementQuantityUSD, ISNULL(MovementValueUSD,0.00) MovementValueUSD  FROM @OpeningUSDTable
END










