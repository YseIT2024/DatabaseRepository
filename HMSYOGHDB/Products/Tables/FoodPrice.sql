CREATE TABLE [Products].[FoodPrice] (
    [PriceID]    INT             NOT NULL,
    [ItemID]     INT             NOT NULL,
    [LocationID] INT             NOT NULL,
    [CurrencyID] INT             NOT NULL,
    [Price]      DECIMAL (18, 4) NULL,
    [CreatedBy]  INT             NULL,
    [CreateDate] DATETIME        NULL,
    CONSTRAINT [PK_FoodPrice] PRIMARY KEY CLUSTERED ([PriceID] ASC, [ItemID] ASC) WITH (FILLFACTOR = 90)
);

