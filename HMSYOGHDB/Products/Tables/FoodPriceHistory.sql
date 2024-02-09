CREATE TABLE [Products].[FoodPriceHistory] (
    [FPHistoryID] INT             NOT NULL,
    [PriceID]     INT             NOT NULL,
    [ItemID]      INT             NOT NULL,
    [LocationID]  INT             NOT NULL,
    [CurrencyID]  INT             NOT NULL,
    [Price]       DECIMAL (18, 4) NOT NULL,
    [HistoryDate] DATETIME        NOT NULL,
    [CreatedBy]   INT             NOT NULL,
    CONSTRAINT [PK_FoodPriceHistory] PRIMARY KEY CLUSTERED ([FPHistoryID] ASC, [PriceID] ASC, [ItemID] ASC) WITH (FILLFACTOR = 90)
);

