

CREATE VIEW [currency].[vwDenominationValue]
AS
SELECT d.DenominationValue, ds.DenomQuantity, rct.Rate,d.DenominationValue * ds.DenomQuantity AS DenomTotal, 
d.DenominationValue * ds.DenomQuantity * rct.Rate AS DenomTotalUSD,ds.AccountingDateId, ds.DrawerID, d.DenominationID, 
dt.DenominationType, dt.DenominationTypeID, c.CurrencyID,c.CurrencyCode, dvt.DenominationValueTypeID,dvt.DenominationValueType, 
d.DenominationValue * ds.DenomQuantity * rct_1.Rate AS DenomTotalNextDay,rct_1.Rate AS CurrencyRateNextDay
FROM currency.Denomination d
INNER JOIN currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID
INNER JOIN currency.DenominationValueType dvt  ON dt.DenominationValueTypeID = dvt.DenominationValueTypeID
INNER JOIN currency.DenominationStatistics ds ON d.DenominationID = ds.DenominationID
INNER JOIN currency.DailyRateChangeHistory rct ON dt.CurrencyID = rct.CurrencyID AND ds.DrawerID = rct.DrawerID AND ds.AccountingDateId = rct.AccountingDateId
AND rct.IsActive =1
INNER JOIN currency.Currency c ON rct.CurrencyID = c.CurrencyID
LEFT OUTER JOIN  currency.DailyRateChangeHistory rct_1 ON c.CurrencyID = rct_1.CurrencyId AND 
ds.DrawerID = rct_1.DrawerID AND ds.AccountingDateId + 1 = rct_1.AccountingDateId AND  rct_1.IsActive =1














