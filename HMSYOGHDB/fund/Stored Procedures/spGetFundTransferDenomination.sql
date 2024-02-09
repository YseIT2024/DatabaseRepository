-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fund].[spGetFundTransferDenomination] --1
(
	@DrawerID INT	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--SELECT DenominationID, DenominationValue, dt.DenominationTypeID, 0 as Quantity, 0.00 as Total, 0.00 as TotalInUSD, dt.CurrencyID, vwc.ExchangeRate FROM
	--[currency].[DenominationType] dt
	--INNER JOIN [currency].[Denomination] d ON dt.DenominationTypeID = d.DenominationTypeID
	--INNER JOIN [currency].[vwCurrentExchangeRate] vwc ON dt.CurrencyID = vwc.CurrencyID  AND vwc.DrawerID = @DrawerID
	--WHERE dt.DenominationValueTypeID = 1 AND d.IsActive = 1

	Declare @AccountingDateId INT =
	(
		Select  [account].[GetAccountingDateIsActive](@DrawerID)
	);

	SELECT  [currency].[DenominationStatistics].DenominationStatisticsID, [currency].[DenominationStatistics].DenominationID, 
	[currency].[Denomination].DenominationValue, [currency].[DenominationType].DenominationTypeID, [currency].[DenominationStatistics].DenomQuantity AS ActualQuantity, 
	[currency].[DenominationStatistics].DenomQuantity AS Quantity,[currency].[DenominationStatistics].DenomTotalValue AS Total, 
	[currency].[DenominationStatistics].DenomTotalValue / vwc.ExchangeRate AS TotalInUSD, [currency].[DenominationType].CurrencyID, vwc.ExchangeRate
	FROM        [currency].[DenominationStatistics]   
	INNER JOIN
	[currency].[Denomination] ON   [currency].[DenominationStatistics].DenominationId = [currency].[Denomination].DenominationId
	INNER JOIN
	[currency].[DenominationType] ON [currency].[Denomination].DenominationTypeId = [currency].[DenominationType].DenominationTypeId
	INNER JOIN 
	[currency].[vwCurrentExchangeRate] vwc ON [currency].[DenominationType].CurrencyID = vwc.CurrencyID  AND vwc.DrawerID = @DrawerID
	WHERE        ([currency].[Denomination].IsActive = 1) AND ([currency].[DenominationType].DenominationValueTypeID = 2) AND 
	( [currency].[DenominationStatistics].AccountingDateId = @AccountingDateId) AND ([currency].[DenominationStatistics].DrawerID = @DrawerID)
	Order by [currency].[Denomination].DenominationValue desc   
	

    SELECT  currency.Currency.CurrencyCode,  ISNULL(Sum(currency.DenominationStatistics.DenomTotalValue),0.00) as Total	
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
	WHERE  currency.DenominationStatistics.AccountingDateId=@AccountingDateId and currency.DenominationStatistics.DrawerID=@DrawerID and
	currency.DenominationType.DenominationValueTypeID = 2
	GROUP BY currency.Currency.CurrencyCode, currency.Currency.CurrencyID	
	ORDER BY currency.Currency.CurrencyID		
END


