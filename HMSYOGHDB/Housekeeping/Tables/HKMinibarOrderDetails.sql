CREATE TABLE [Housekeeping].[HKMinibarOrderDetails] (
    [OrderDetailId]        INT             IDENTITY (1, 1) NOT NULL,
    [OrderId]              INT             NULL,
    [ItemId]               INT             NULL,
    [Quantity]             INT             NULL,
    [Rate]                 DECIMAL (18, 6) NULL,
    [TaxId]                INT             NULL,
    [TaxPer]               DECIMAL (18, 6) NULL,
    [ServiceCharge]        DECIMAL (18, 6) NULL,
    [ReturnQty]            INT             NULL,
    [ReturnDate]           DATETIME        NULL,
    [Remarks]              VARCHAR (250)   NULL,
    [CreatedBy]            INT             NULL,
    [CreatedOn]            DATETIME        NULL,
    [ModifiedOn]           DATETIME        NULL,
    [ModifiedBy]           INT             NULL,
    [IsActive]             BIT             NULL,
    [TotalAmountBeforeTax] DECIMAL (18, 6) NULL,
    [TotalAmountAfterTax]  DECIMAL (18, 6) NULL,
    [LineTaxAmt]           DECIMAL (18, 6) NULL,
    CONSTRAINT [PK_HKMinibarOrderDetails] PRIMARY KEY CLUSTERED ([OrderDetailId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__HKMinibarOrderDetails] FOREIGN KEY ([OrderId]) REFERENCES [Housekeeping].[HKMinibarOrder] ([OrderId])
);

