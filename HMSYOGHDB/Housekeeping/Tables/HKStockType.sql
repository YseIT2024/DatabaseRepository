CREATE TABLE [Housekeeping].[HKStockType] (
    [LocationId]    INT           NOT NULL,
    [StockTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [StockTypeName] VARCHAR (250) NOT NULL,
    [IsActive]      BIT           NOT NULL,
    CONSTRAINT [PK_HKStockType] PRIMARY KEY CLUSTERED ([StockTypeID] ASC) WITH (FILLFACTOR = 90)
);

