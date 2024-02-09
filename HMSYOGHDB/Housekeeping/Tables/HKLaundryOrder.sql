﻿CREATE TABLE [Housekeeping].[HKLaundryOrder] (
    [OrderId]              INT            IDENTITY (1, 1) NOT NULL,
    [OrdereDate]           DATETIME       NOT NULL,
    [FolioNumber]          INT            NOT NULL,
    [GuestID]              INT            NOT NULL,
    [RoomNo]               INT            NOT NULL,
    [TotalAmountBeforeTax] DECIMAL (6, 2) NOT NULL,
    [Discount]             DECIMAL (6, 2) NOT NULL,
    [ServiceCharge]        DECIMAL (6, 2) NOT NULL,
    [TaxAmount]            DECIMAL (6, 2) NOT NULL,
    [TotalAmountAfterTax]  DECIMAL (6, 2) NOT NULL,
    [CashPaid]             DECIMAL (6, 2) NOT NULL,
    [PINPaid]              DECIMAL (6, 2) NOT NULL,
    [ReturnAmount]         DECIMAL (6, 2) NOT NULL,
    [OrderStatus]          INT            NOT NULL,
    [PrintStatus]          INT            NOT NULL,
    [Remarks]              VARCHAR (250)  NULL,
    [CreatedBy]            INT            NOT NULL,
    [Createdon]            DATETIME       NOT NULL,
    [ModifiedOn]           DATETIME       NULL,
    [ModifiedBy]           INT            NULL,
    [IsExpress]            BIT            NOT NULL,
    [ItemCount]            INT            NOT NULL,
    [IsActive]             BIT            NOT NULL,
    [LaundryType]          INT            NOT NULL,
    [TaxAmt]               DECIMAL (6, 2) NULL,
    [RoomID]               INT            NULL,
    CONSTRAINT [PK_HKLundryOrder] PRIMARY KEY CLUSTERED ([OrderId] ASC) WITH (FILLFACTOR = 90)
);
