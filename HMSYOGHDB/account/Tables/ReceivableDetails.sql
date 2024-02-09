CREATE TABLE [account].[ReceivableDetails] (
    [ReceivableDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [ReceivableId]       INT             NULL,
    [AccountTypeId]      INT             NULL,
    [DescriptionId]      INT             NULL,
    [Quantity]           DECIMAL (18, 2) NULL,
    [Rate]               DECIMAL (18, 2) NULL,
    [Amount]             DECIMAL (18, 2) NULL,
    [SubTotal]           DECIMAL (18, 2) NULL,
    [TaxRate]            DECIMAL (18, 2) NULL,
    [SalesTax]           DECIMAL (18, 2) NULL,
    [Others]             DECIMAL (18, 2) NULL,
    [Total]              DECIMAL (18, 2) NULL,
    [CreatedOn]          DATETIME        NULL,
    [IsActive]           BIT             NULL,
    [TotalAmount]        DECIMAL (18, 2) NULL
);

