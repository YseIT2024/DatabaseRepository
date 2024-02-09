CREATE TYPE [currency].[dtDenominationStatisticsDetails] AS TABLE (
    [ID]                                 INT             NOT NULL,
    [DenominationStatisticsID]           INT             NOT NULL,
    [DenomQuantity]                      INT             NOT NULL,
    [DenomTotalValue]                    DECIMAL (18, 2) NOT NULL,
    [DenominationTotalMainCurrencyValue] DECIMAL (18, 2) NOT NULL,
    [CurrencyID]                         INT             NULL);

