CREATE TABLE [Products].[ItemDetails] (
    [ItemDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [ParentIemID]  INT             NULL,
    [ItemID]       INT             NOT NULL,
    [UOMID]        INT             NOT NULL,
    [Quantity]     DECIMAL (12, 2) NOT NULL,
    [Price]        DECIMAL (18, 4) NULL,
    [CreatedBy]    INT             NULL,
    [CreateDate]   DATETIME        NULL,
    CONSTRAINT [PK_ItemDetails] PRIMARY KEY CLUSTERED ([ItemDetailID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ItemDetails_Item] FOREIGN KEY ([ParentIemID]) REFERENCES [Products].[Item] ([ItemID])
);

