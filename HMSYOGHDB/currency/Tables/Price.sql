CREATE TABLE [currency].[Price] (
    [PriceID]    INT             IDENTITY (1, 1) NOT NULL,
    [Rate]       DECIMAL (18, 2) NOT NULL,
    [CurrencyID] INT             NOT NULL,
    CONSTRAINT [PK_Price_1] PRIMARY KEY CLUSTERED ([PriceID] ASC) WITH (FILLFACTOR = 90)
);

