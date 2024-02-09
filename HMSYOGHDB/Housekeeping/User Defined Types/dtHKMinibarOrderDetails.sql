CREATE TYPE [Housekeeping].[dtHKMinibarOrderDetails] AS TABLE (
    [ItemID]      INT             NULL,
    [ItemRate]    DECIMAL (18, 6) NULL,
    [TaxId]       INT             NULL,
    [TaxPercent]  DECIMAL (18, 6) NULL,
    [Quantity]    INT             NULL,
    [TotalAmount] DECIMAL (18, 6) NULL,
    [ReturnQty]   INT             NULL,
    [ReturnDate]  DATETIME        NULL,
    [Remarks]     VARCHAR (250)   NULL);

