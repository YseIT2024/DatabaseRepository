CREATE TABLE [guest].[CompanyInvoiceStatementDetails] (
    [CISDID]               INT             IDENTITY (1, 1) NOT NULL,
    [CISID]                INT             NOT NULL,
    [InvoiceNo]            INT             NULL,
    [TotalAmountBeforeTax] DECIMAL (18, 2) NULL,
    [TotalTaxAmount]       DECIMAL (18, 2) NULL,
    [ServiceTaxAmount]     DECIMAL (18, 2) NULL,
    [TotalAmountAfterTax]  DECIMAL (18, 4) NULL,
    [AdditionalDiscount]   DECIMAL (18, 4) NULL,
    [RoundOffAmount]       DECIMAL (18, 4) NULL,
    [TotalAmountNet]       DECIMAL (18, 4) NULL,
    [CreatedBy]            INT             NULL,
    [Created]              DATETIME        NULL,
    CONSTRAINT [PK_CISDID] PRIMARY KEY CLUSTERED ([CISDID] ASC) WITH (FILLFACTOR = 90)
);

