CREATE TYPE [reservation].[SplitInvoiceDetails] AS TABLE (
    [TransDate]       DATETIME        NULL,
    [ItemId]          INT             NULL,
    [ItemDescription] NVARCHAR (150)  NULL,
    [Quantity]        INT             NULL,
    [Rate]            DECIMAL (18, 2) NULL,
    [Amount]          DECIMAL (18, 2) NULL,
    [TaxPercentage]   DECIMAL (18, 2) NULL,
    [TaxAmount]       DECIMAL (18, 2) NULL,
    [TaxId]           INT             NULL,
    [AmountBeforeTax] DECIMAL (18, 2) NULL);

