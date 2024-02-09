CREATE TABLE [reservation].[ReservationCancellation] (
    [CancellationId]     INT            IDENTITY (1, 1) NOT NULL,
    [FolioNumber]        INT            NULL,
    [ReservationID]      INT            NOT NULL,
    [CancellationReason] NVARCHAR (100) NULL,
    [ActionID]           INT            NOT NULL,
    [StatusID]           INT            NOT NULL,
    [UserID]             INT            NOT NULL,
    [DateTime]           DATETIME       NOT NULL,
    [IsActive]           BIT            NOT NULL,
    CONSTRAINT [PK_ReservationCancellation] PRIMARY KEY CLUSTERED ([ReservationID] ASC) WITH (FILLFACTOR = 90)
);

