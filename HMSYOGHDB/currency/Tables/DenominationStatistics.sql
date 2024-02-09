CREATE TABLE [currency].[DenominationStatistics] (
    [DenominationStatisticsID]           INT             IDENTITY (1, 1) NOT NULL,
    [DenominationID]                     INT             NOT NULL,
    [DenomQuantity]                      INT             NOT NULL,
    [DenomTotalValue]                    DECIMAL (18, 3) NOT NULL,
    [AccountingDateId]                   INT             NOT NULL,
    [DrawerID]                           INT             NOT NULL,
    [DenominationTotalMainCurrencyValue] DECIMAL (18, 3) NOT NULL,
    CONSTRAINT [PK_DenominationStatistics] PRIMARY KEY CLUSTERED ([DenominationStatisticsID] ASC) WITH (FILLFACTOR = 90)
);

