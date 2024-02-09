CREATE TABLE [Inventory].[PurchaseIndentDetails] (
    [SLNo]     INT             NOT NULL,
    [PIID]     INT             NOT NULL,
    [ItemID]   INT             NOT NULL,
    [UomID]    INT             NOT NULL,
    [Quantity] DECIMAL (12, 2) NOT NULL,
    CONSTRAINT [PK_PurchaseIndentDetails] PRIMARY KEY CLUSTERED ([SLNo] ASC, [PIID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_PurchaseIndentDetails_PurchaseIndentDetails] FOREIGN KEY ([SLNo], [PIID]) REFERENCES [Inventory].[PurchaseIndentDetails] ([SLNo], [PIID])
);

