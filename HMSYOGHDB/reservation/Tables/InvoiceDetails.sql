CREATE TABLE [reservation].[InvoiceDetails] (
    [InvoiceDetailsId]        INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]               INT             NOT NULL,
    [TransactionDate]         DATETIME        NULL,
    [ServiceId]               INT             NULL,
    [ServiceDescription]      NVARCHAR (250)  NULL,
    [SACNo]                   INT             NULL,
    [ServiceRate]             DECIMAL (18, 2) NULL,
    [ServiceQty]              INT             NULL,
    [TaxId]                   INT             NULL,
    [TaxPercent]              DECIMAL (18, 2) NULL,
    [AmountBeforeTax]         DECIMAL (18, 2) NULL,
    [TaxAmount]               DECIMAL (18, 2) NULL,
    [AmountAfterTax]          DECIMAL (18, 2) NULL,
    [DisplaySequence]         INT             NULL,
    [BillingCode]             INT             NULL,
    [IsComplimentary]         BIT             NULL,
    [ComplimentaryPercentage] DECIMAL (18, 2) NULL,
    [Discount]                DECIMAL (18, 2) NULL,
    [UnitPriceBeforeDiscount] DECIMAL (18, 2) NULL,
    [DiscountPercentage]      DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_InvoiceDetails] PRIMARY KEY CLUSTERED ([InvoiceDetailsId] ASC) WITH (FILLFACTOR = 90)
);

