CREATE TABLE [Products].[RoomLogs] (
    [RSHistoryID]     BIGINT   IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RoomID]          INT      NOT NULL,
    [FromDateID]      INT      NOT NULL,
    [ToDateID]        INT      CONSTRAINT [DF_RoomLogs_Cancelled] DEFAULT ((0)) NOT NULL,
    [RoomStatusID]    INT      NULL,
    [FromDate]        DATETIME NULL,
    [ToDate]          DATETIME NULL,
    [ReservationID]   INT      NULL,
    [CreatedBy]       INT      NULL,
    [CreateDate]      DATETIME NULL,
    [IsPrimaryStatus] BIT      NULL,
    CONSTRAINT [PK_RoomLogs] PRIMARY KEY CLUSTERED ([RSHistoryID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RoomLogs_Room] FOREIGN KEY ([RoomID]) REFERENCES [Products].[Room] ([RoomID])
);

