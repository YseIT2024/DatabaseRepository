CREATE TYPE [guest].[dtCreateCompanyInvoiceStatement] AS TABLE (
    [CISDID]               INT             NULL,
    [CISID]                INT             NULL,
    [InvoiceNumber]        INT             NULL,
    [TotalAmountBeforeTax] DECIMAL (18, 4) NULL,
    [TotalTaxAmount]       DECIMAL (18, 4) NULL,
    [ServiceTaxAmount]     DECIMAL (18, 4) NULL,
    [TotalAmountAfterTax]  DECIMAL (18, 4) NULL,
    [AdditionalDiscount]   DECIMAL (18, 4) NULL,
    [RoundOffAmount]       DECIMAL (18, 4) NULL,
    [TotalAmountNet]       DECIMAL (18, 4) NULL);

