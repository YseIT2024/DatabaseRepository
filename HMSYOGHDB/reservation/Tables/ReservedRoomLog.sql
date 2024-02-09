CREATE TABLE [reservation].[ReservedRoomLog] (
    [LogID]         INT      IDENTITY (1, 1) NOT NULL,
    [ReservationID] INT      NOT NULL,
    [RoomID]        INT      NOT NULL,
    [Date]          DATETIME NOT NULL,
    [UserID]        INT      NOT NULL,
    CONSTRAINT [PK_ReservedRoomLog] PRIMARY KEY CLUSTERED ([LogID] ASC) WITH (FILLFACTOR = 90)
);

