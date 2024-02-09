CREATE TABLE [currency].[DailyRateChangeHistory] (
    [ID]                         INT             IDENTITY (1, 1) NOT NULL,
    [DrawerID]                   INT             NOT NULL,
    [AccountingDateID]           INT             NOT NULL,
    [CurrencyID]                 INT             NOT NULL,
    [ExchangeRateToCurrencyID]   INT             NOT NULL,
    [Rate]                       DECIMAL (18, 6) NOT NULL,
    [IsStrongerThanMainCurrency] BIT             CONSTRAINT [DF_DailyRateChangeHistory_IsStrongerThanMainCurrency] DEFAULT ((0)) NOT NULL,
    [IsActive]                   BIT             CONSTRAINT [DF_DailyRateChangeHistory_IsActive] DEFAULT ((1)) NOT NULL
);

