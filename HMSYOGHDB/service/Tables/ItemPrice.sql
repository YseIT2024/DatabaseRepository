CREATE TABLE [service].[ItemPrice] (
    [ItemPriceID] INT             IDENTITY (1, 1) NOT NULL,
    [ItemID]      INT             NOT NULL,
    [ItemRate]    DECIMAL (18, 2) NOT NULL,
    [ValidFrom]   DATETIME        NOT NULL,
    [ValidTo]     DATETIME        NOT NULL,
    [IsActive]    BIT             NOT NULL,
    [CreatedBy]   INT             NOT NULL,
    [CreatedOn]   DATETIME        NOT NULL,
    [ModifiedBy]  INT             NULL,
    [ModifiedOn]  DATETIME        NULL,
    [Discount]    DECIMAL (18)    NULL,
    CONSTRAINT [PK_ItemPrice] PRIMARY KEY CLUSTERED ([ItemPriceID] ASC) WITH (FILLFACTOR = 90)
);

