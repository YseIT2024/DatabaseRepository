﻿CREATE TABLE [reservation].[Invoice] (
    [InvoiceNo]            INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceDate]          DATE            NULL,
    [FolioNumber]          INT             NOT NULL,
    [GuestID]              INT             NOT NULL,
    [GRCNo]                NVARCHAR (30)   NULL,
    [GSTIN]                NVARCHAR (30)   NULL,
    [TotalAmountBeforeTax] DECIMAL (18, 2) NULL,
    [VatAmount]            DECIMAL (18, 2) NULL,
    [ServiceTaxAmount]     DECIMAL (18, 2) NULL,
    [TotalAmountAfterTax]  DECIMAL (18, 4) NULL,
    [AdditionalDiscount]   DECIMAL (18, 4) NULL,
    [RoundOffAmount]       DECIMAL (18, 4) NULL,
    [TotalAmountNet]       DECIMAL (18, 4) NULL,
    [InvoiceStatus]        INT             NOT NULL,
    [PrintStatus]          INT             NOT NULL,
    [Remarks]              NVARCHAR (100)  NULL,
    [CreatedBy]            INT             NOT NULL,
    [Createdon]            DATETIME        NULL,
    [ModifiedOn]           DATE            NULL,
    [ModifiedBy]           INT             NULL,
    [BillToType]           NVARCHAR (150)  NULL,
    [ParentInvoiceNo]      INT             NULL,
    [TotalReceived]        DECIMAL (18, 4) NULL,
    [Balance]              DECIMAL (18, 4) NULL,
    [BillTo]               INT             NULL,
    [InvoiceNumber]        NVARCHAR (50)   NULL,
    CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED ([InvoiceNo] ASC) WITH (FILLFACTOR = 90)
);

