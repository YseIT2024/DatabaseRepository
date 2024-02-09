CREATE TABLE [reservation].[ReservationStatusLog] (
    [ID]                  INT           IDENTITY (1, 1) NOT NULL,
    [ReservationID]       INT           NULL,
    [ReservationStatusID] INT           NULL,
    [Remarks]             VARCHAR (350) NULL,
    [UserID]              INT           NOT NULL,
    [DateTime]            DATETIME      NOT NULL,
    [ReservedRoomRateID]  INT           NULL,
    CONSTRAINT [PK_ReservationStatusLog] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ReservationStatusLog_Reservation] FOREIGN KEY ([ReservationID]) REFERENCES [reservation].[Reservation] ([ReservationID])
);

