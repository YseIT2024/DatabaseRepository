﻿CREATE TABLE [Finance].[Payments] (
    [PaymentId]              INT            IDENTITY (1, 1) NOT NULL,
    [PaymentNo]              NVARCHAR (50)  NULL,
    [PaymentDate]            DATETIME       NULL,
    [TransactionTypeId]      INT            NOT NULL,
    [TransactionReferenceId] INT            NOT NULL,
    [PayNoteRefernceId]      INT            NULL,
    [CurrencyId]             INT            NULL,
    [Remarks]                NVARCHAR (250) NULL,
    [AccountingDateId]       INT            NULL,
    [StatusId]               INT            NULL,
    [ClientId]               INT            NULL,
    [TillId]                 INT            NULL,
    [LocationId]             INT            NULL,
    [AddedBy]                INT            NULL,
    [AddedOn]                DATETIME       NULL,
    [ModifiedBy]             INT            NULL,
    [ModifiedOn]             DATETIME       NULL,
    [ApprovedBy]             INT            NULL,
    [RejectedBy]             INT            NULL,
    [RejectReason]           NVARCHAR (250) NULL,
    [VerifiedBy]             INT            NULL,
    [PaidDate]               DATETIME       NULL,
    [CollectorType]          INT            NULL,
    [CollectorId]            INT            NULL,
    [PaymentRefId]           NVARCHAR (250) NULL,
    [PaidRemarks]            NVARCHAR (255) NULL,
    [CancelledBy]            INT            NULL,
    [BankPaidUpdatedBy]      INT            NULL
);
