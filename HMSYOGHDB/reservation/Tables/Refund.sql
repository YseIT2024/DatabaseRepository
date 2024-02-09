CREATE TABLE [reservation].[Refund] (
    [RefundId]          INT           IDENTITY (1, 1) NOT NULL,
    [RefundDate]        DATETIME      NULL,
    [CancellationID]    INT           NULL,
    [TransactionModeID] INT           NULL,
    [CreatedOn]         DATETIME      NULL,
    [CreatedBy]         INT           NULL,
    [ModifiedOn]        DATETIME      NULL,
    [ModifiedBy]        INT           NULL,
    [RefundAmount]      DECIMAL (18)  NULL,
    [CancellationMode]  NVARCHAR (50) NULL,
    [CancellationDate]  DATETIME      NULL,
    [ReservationId]     INT           NULL,
    [GuestId]           INT           NULL,
    [GuestName]         NVARCHAR (50) NULL,
    [Address]           NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([RefundId] ASC) WITH (FILLFACTOR = 90)
);

