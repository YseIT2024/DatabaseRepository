


CREATE PROCEDURE [currency].[spDenominationTotalValueInUSD] --5
(
	@DrawerID int
)
	
AS
BEGIN
	Declare @AccountingDate Date
	Declare @AccountingDateId int
	Declare @ExchangeRate Decimal(18,4)
	

	Select @AccountingDateId = [Account].[GetAccountingDateIsActive](@DrawerID)

	SELECT    @AccountingDate = AccountingDate 
	FROM        [account].[AccountingDates]
	WHERE     ([account].[AccountingDates].IsActive = 1) AND ([account].[AccountingDates].DrawerID = @DrawerID)
	

	Declare @TempCountDenomination int = 1
	Declare @DenominationCount int


	Declare @DenominationBalance Table(ID int identity(1,1), DenominationTypeDescription Varchar(100), Total Decimal(18,2), TotalInUSD decimal(18,2), CurrencyId int, DenominationValueTypeId int, DenominationValueType varchar(30))
	
		Insert Into @DenominationBalance(DenominationTypeDescription, Total,TotalInUSD, CurrencyId, DenominationValueTypeId, DenominationValueType)
			SELECT        currency.Currency.CurrencyCode,  ISNULL(Sum(currency.DenominationStatistics.DenomTotalValue),0.00) as Total,
			ISNULL(Sum(currency.DenominationStatistics.DenomTotalValue / vwc.ExchangeRate)  ,0.00) AS TotalInUSD,currency.DenominationType.CurrencyID, 
			currency.DenominationValueType.DenominationValueTypeID,currency.DenominationValueType.DenominationValueType
			FROM  currency.DenominationStatistics  
			INNER JOIN 
			currency.Denomination  ON currency.DenominationStatistics.DenominationID = currency.Denomination.DenominationID
			INNER JOIN
			currency.DenominationType ON currency.Denomination.DenominationTypeID = currency.DenominationType.DenominationTypeID 
			INNER JOIN
			currency.Currency ON currency.DenominationType.CurrencyID = currency.Currency.CurrencyID 
			INNER JOIN
			[currency].[vwCurrentExchangeRate] vwc ON currency.Currency.CurrencyID = vwc.CurrencyID  AND vwc.DrawerID = @DrawerID
			INNER JOIN
			currency.DenominationValueType ON currency.DenominationType.DenominationValueTypeID = currency.DenominationValueType.DenominationValueTypeID		
			WHERE  currency.DenominationStatistics.AccountingDateId=@AccountingDateId and currency.DenominationStatistics.DrawerID=@DrawerID
			AND currency.DenominationType.IsActive=1
			GROUP BY currency.Currency.CurrencyCode,currency.DenominationType.CurrencyID, currency.DenominationValueType.DenominationValueType,currency.DenominationValueType.DenominationValueTypeID	
			


	Select DenominationTypeDescription, ISNULL(Total,0.00) As Total,ISNULL(TotalInUSD,0.00) TotalInUSD, CurrencyId,DenominationValueTypeId,DenominationValueType  From @DenominationBalance



END










