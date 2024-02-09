
CREATE PROCEDURE [report].[spGetCasinoOrHotelCashFigureSummary] 
(
	@DenominationValueTypeID int = NULL,
	@DrawerID int,
	@AccountingDateId int
)
AS
BEGIN	
	IF(@DenominationValueTypeID IS NULL)
		BEGIN
			SELECT d.DenominationTypeID, dvt.DenominationValueType, dt.DenominationType
			,SUM(ds.DenomTotalValue) [DenomTotal]
			,SUM(ds.DenominationTotalMainCurrencyValue) [DenomTotalUSD]
			,c.CurrencySymbol
			FROM currency.DenominationValueType dvt
			INNER JOIN currency.DenominationType dt ON dvt.DenominationValueTypeID = dt.DenominationValueTypeID
			INNER JOIN currency.Denomination d ON dt.DenominationTypeID = d.DenominationTypeID
			INNER JOIN currency.DenominationStatistics ds ON d.DenominationID = ds.DenominationID
			INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID
			WHERE ds.DrawerID = @DrawerID AND ds .AccountingDateId = @AccountingDateId
			GROUP BY d.DenominationTypeID, dt.DenominationType, dvt.DenominationValueType, c.CurrencySymbol
		END
	ELSE
		BEGIN
			SELECT d.DenominationTypeID, dvt.DenominationValueType, dt.DenominationType
			,SUM(ds.DenomTotalValue) [DenomTotal]
			,SUM(ds.DenominationTotalMainCurrencyValue) [DenomTotalUSD]
			,c.CurrencySymbol
			FROM currency.DenominationValueType dvt
			INNER JOIN currency.DenominationType dt ON dvt.DenominationValueTypeID = dt.DenominationValueTypeID
			INNER JOIN currency.Denomination d ON dt.DenominationTypeID = d.DenominationTypeID
			INNER JOIN currency.DenominationStatistics ds ON d.DenominationID = ds.DenominationID
			INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID
			WHERE ds.DrawerID = @DrawerID AND ds .AccountingDateId = @AccountingDateId AND dvt.DenominationValueTypeID = @DenominationValueTypeID
			GROUP BY d.DenominationTypeID, dt.DenominationType, dvt.DenominationValueType, c.CurrencySymbol
		END
END

