CREATE TABLE [Housekeeping].[HKMISCInvoiceDetails] (
    [InvoiceDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]       INT            NULL,
    [ItemId]          INT            NULL,
    [ItemDescription] VARCHAR (100)  NULL,
    [Quantity]        INT            NULL,
    [Rate]            DECIMAL (6, 2) NULL,
    [TaxId]           INT            NULL,
    [TaxPer]          DECIMAL (6, 2) NULL,
    [ServiceCharge]   DECIMAL (6, 2) NULL,
    [TotalRate]       DECIMAL (6, 2) NULL,
    [Remarks]         VARCHAR (250)  NULL,
    [CreatedBy]       INT            NULL,
    [Createdon]       DATETIME       NULL,
    [ModifiedOn]      DATETIME       NULL,
    [ModifiedBy]      INT            NULL,
    [IsActive]        BIT            NULL,
    CONSTRAINT [PK_HKMISCInvoiceDetails] PRIMARY KEY CLUSTERED ([InvoiceDetailId] ASC) WITH (FILLFACTOR = 90)
);

