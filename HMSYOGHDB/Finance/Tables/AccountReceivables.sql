﻿CREATE TABLE [Finance].[AccountReceivables] (
    [AccountReceivableId] INT             IDENTITY (1, 1) NOT NULL,
    [AccountType]         NVARCHAR (20)   NULL,
    [ExpenseTypeId]       INT             NULL,
    [SupplierId]          INT             NULL,
    [CreatedDate]         DATETIME        NULL,
    [CurrencyId]          INT             NULL,
    [Balance]             DECIMAL (18, 2) NULL,
    [PaymentTypeId]       INT             NULL,
    [ExpenseDescription]  NVARCHAR (200)  NULL,
    [InvoiceNo]           NVARCHAR (20)   NULL,
    [Term]                NVARCHAR (20)   NULL,
    [DueDate]             DATETIME        NULL,
    [InvoiceAmt]          DECIMAL (18, 2) NULL,
    [AmountReceived]      DECIMAL (18, 2) NULL,
    [AmountReceivedUSD]   DECIMAL (18, 2) NULL,
    [ExchangeRate]        DECIMAL (18, 2) NULL,
    [ValidationVal]       BIT             NULL,
    [ScheduleId]          INT             NULL,
    [StartDate]           DATETIME        NULL,
    [ExpirationDate]      DATETIME        NULL,
    [ScheduleTypeId]      INT             NULL,
    [ScheduleDescription] NVARCHAR (20)   NULL,
    [ScheduleExpire]      BIT             NULL,
    [AddedBy]             INT             NULL,
    [ClientId]            INT             NULL,
    [TillId]              INT             NULL,
    [LocationId]          INT             NULL,
    [AccountingDateId]    INT             NOT NULL,
    [isActive]            BIT             NULL,
    [ModifiedBy]          INT             NULL,
    [AccountEntryTypeId]  INT             NULL,
    [Bank]                NVARCHAR (200)  NULL,
    [AccountNo]           NVARCHAR (20)   NULL,
    [ChequeNo]            NVARCHAR (20)   NULL,
    [CardName]            NVARCHAR (200)  NULL,
    [CardNo]              NVARCHAR (20)   NULL,
    [MobileNo]            NVARCHAR (20)   NULL,
    [Pin]                 NVARCHAR (20)   NULL,
    [ReferenceScheduleId] INT             NULL,
    [AccountEntryType]    INT             NULL,
    [Total]               DECIMAL (18, 2) NULL,
    [TaxRate]             DECIMAL (18, 2) NULL,
    [SalesTax]            DECIMAL (18, 2) NULL,
    [SubTotal]            DECIMAL (18, 2) NULL,
    [StatusId]            INT             NULL,
    [ApprovedBy]          INT             NULL,
    [VerifiedBy]          INT             NULL,
    [RejectedBy]          INT             NULL,
    [RejectReason]        NVARCHAR (500)  NULL,
    [CancelledBy]         INT             NULL,
    [ModifiedOn]          DATETIME        NULL,
    [ProjectId]           INT             NULL,
    [InvoiceNotes]        NVARCHAR (800)  NULL,
    [SalesOrderNumber]    NVARCHAR (100)  NULL,
    [SalesOrderId]        INT             NULL,
    [CollectorId]         INT             NULL,
    [CollectorType]       INT             NULL,
    [PaidToTypeId]        INT             NULL,
    [FrmBillAddress]      NVARCHAR (755)  NULL,
    [ToBillAddress]       NVARCHAR (755)  NULL,
    [FrmBank]             NVARCHAR (125)  NULL,
    [FrmAccountNo]        NVARCHAR (125)  NULL
);

