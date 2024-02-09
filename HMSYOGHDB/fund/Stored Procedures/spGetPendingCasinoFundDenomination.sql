-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fund].[spGetPendingCasinoFundDenomination]
(
	@FundFlowID INT
)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @Denomination TABLE(DenominationTypeID INT, DenominationType VARCHAR(20), DenominationID INT, 
	Denomination DECIMAL(18,2), Quantity INT, Total DECIMAL(18,2), TotalInUSD DECIMAL(18,2), CurrencyID INT, ExchangeRate DECIMAL(18,2))

	INSERT INTO @Denomination(DenominationTypeID, DenominationType, DenominationID, Denomination, Quantity, Total, 
	TotalInUSD, CurrencyID, ExchangeRate)
	SELECT  d.DenominationTypeID,  dt.DenominationType, ds.DenominationID, 
	d.DenominationValue, ds.Quantity, ds.TotalValue, ds.TotalValue/ExchangeRate, dt.CurrencyID, ExchangeRate
	FROM currency.DenominationValueType dvt
	INNER JOIN currency.DenominationType dt ON dvt.DenominationValueTypeID = dt.DenominationValueTypeID
	INNER JOIN currency.Denomination d ON dt.DenominationTypeID = d.DenominationTypeID
	INNER JOIN[currency].[vwCurrentExchangeRate] vwc ON dt.CurrencyID = vwc.CurrencyID  AND vwc.DrawerID = 1
	LEFT JOIN fund.Denomination ds ON d.DenominationID = ds.DenominationID	
	WHERE ds.FundFlowID = @FundFlowID  AND dvt.DenominationValueTypeID = 2

	UNION ALL

	SELECT  d.DenominationTypeID,  dt.DenominationType, d.DenominationID, 
	d.DenominationValue [Denomination], 0 , 0.00, 0.00, dt.CurrencyID, ExchangeRate
	FROM currency.DenominationValueType dvt
	INNER JOIN currency.DenominationType dt ON dvt.DenominationValueTypeID = dt.DenominationValueTypeID
	INNER JOIN currency.Denomination d ON dt.DenominationTypeID = d.DenominationTypeID
	INNER JOIN [currency].[vwCurrentExchangeRate] vwc ON dt.CurrencyID = vwc.CurrencyID  AND vwc.DrawerID = 1 
	WHERE dvt.DenominationValueTypeID = 2

	SELECT DenominationTypeID, DenominationType, DenominationID, Denomination, SUM(Quantity) Quantity, SUM(Total) Total, SUM(TotalInUSD) TotalInUSD, CurrencyID, ExchangeRate 
	FROM @Denomination
	GROUP BY DenominationTypeID, DenominationType, DenominationID, Denomination,CurrencyID, ExchangeRate
	ORDER BY DenominationTypeID	

	SELECT USDAmount, SRDAmount, EURAmount FROM fund.Flow 
	WHERE FundFlowID = @FundFlowID
END

