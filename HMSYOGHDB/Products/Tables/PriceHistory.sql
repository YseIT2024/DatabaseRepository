CREATE TABLE [Products].[PriceHistory] (
    [PriceHistoryID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [ItemID]         INT             NOT NULL,
    [HistoryDate]    DATETIME        NULL,
    [CurrencyID]     INT             NOT NULL,
    [Price]          DECIMAL (18, 4) NULL,
    [CreatedBy]      INT             NULL,
    [CreateDate]     DATETIME        NULL
);

