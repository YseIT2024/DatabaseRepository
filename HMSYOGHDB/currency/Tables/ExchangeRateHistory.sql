CREATE TABLE [currency].[ExchangeRateHistory] (
    [ID]                         INT             IDENTITY (1, 1) NOT NULL,
    [LocationID]                 INT             NOT NULL,
    [DrawerID]                   INT             CONSTRAINT [DF_ExchangeRateHistory_DrawerID] DEFAULT ((1)) NOT NULL,
    [CurrencyID]                 INT             NOT NULL,
    [ExchangeRateToCurrencyID]   INT             CONSTRAINT [DF_ExchangeRateHistory_ExchangeRateToCurrencyID] DEFAULT ((1)) NOT NULL,
    [OldRate]                    DECIMAL (18, 6) NOT NULL,
    [NewRate]                    DECIMAL (18, 6) NOT NULL,
    [IsStrongerThanMainCurrency] BIT             CONSTRAINT [DF_ExchangeRateHistory_IsStrongerThanMainCurrency] DEFAULT ((0)) NOT NULL,
    [AccountingDate]             DATETIME        NOT NULL,
    [RateChangeTime]             DATETIME        CONSTRAINT [DF_ExchangeRateHistory_RateChangeTime] DEFAULT (getdate()) NOT NULL,
    [UserID]                     INT             NOT NULL,
    [IsActive]                   BIT             NOT NULL,
    [OldBRate]                   DECIMAL (18, 6) NULL,
    [NewBRate]                   DECIMAL (18, 6) NULL,
    CONSTRAINT [PK_ExchangeRateHistory] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

