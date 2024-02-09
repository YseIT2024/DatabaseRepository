
CREATE PROCEDURE [account].[spGetDenominationByCurrency]
(
	@CurrencyID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [DenominationID]      
	,[DenominationValue] [Denom]
	,0 [Quantity]
	,0.00 [DenomTotal]
	FROM [currency].[Denomination] d
	INNER JOIN currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID
	WHERE d.IsActive = 1 AND dt.CurrencyID = @CurrencyID AND dt.DenominationValueTypeID = 1
END
