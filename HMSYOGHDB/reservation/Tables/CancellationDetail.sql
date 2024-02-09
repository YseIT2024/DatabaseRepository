CREATE TABLE [reservation].[CancellationDetail] (
    [CancellationID]      INT             IDENTITY (1, 1) NOT NULL,
    [ReservationID]       INT             NOT NULL,
    [CancellationModeID]  INT             NOT NULL,
    [CancellationCharge]  DECIMAL (18, 4) NOT NULL,
    [Refund]              DECIMAL (18, 4) NULL,
    [CreatedBy]           INT             NULL,
    [CreatedDate]         DATETIME        NULL,
    [Reason]              VARCHAR (350)   NULL,
    [RequestedOn]         DATETIME        NOT NULL,
    [ReservationStatusID] INT             NULL,
    CONSTRAINT [PK_reservation.Cancellation] PRIMARY KEY CLUSTERED ([CancellationID] ASC) WITH (FILLFACTOR = 90)
);

