CREATE TABLE [reservation].[ProvisionalInvoiceDetails] (
    [InvoiceDetailsId]   INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]          INT             NOT NULL,
    [TransactionDate]    DATETIME        NULL,
    [ServiceId]          INT             NULL,
    [ServiceDescription] NVARCHAR (250)  NULL,
    [SACNo]              INT             NULL,
    [ServiceRate]        DECIMAL (18, 2) NULL,
    [ServiceQty]         INT             NULL,
    [TaxId]              INT             NULL,
    [TaxPercent]         DECIMAL (18, 2) NULL,
    [AmountBeforeTax]    DECIMAL (18, 2) NULL,
    [TaxAmount]          DECIMAL (18, 2) NULL,
    [AmountAfterTax]     DECIMAL (18, 2) NULL,
    [DisplaySequence]    INT             NULL,
    [BillingCode]        INT             NULL,
    CONSTRAINT [PK_ProvisionalInvoiceDetails] PRIMARY KEY CLUSTERED ([InvoiceDetailsId] ASC) WITH (FILLFACTOR = 90)
);

