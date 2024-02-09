CREATE TABLE [BQTReservation].[Events] (
    [EventId]      INT           IDENTITY (1, 1) NOT NULL,
    [EventName]    VARCHAR (100) NULL,
    [EventTypeId]  INT           NULL,
    [CreatedBy]    INT           NULL,
    [ModifiedBy]   INT           NULL,
    [CreatedDate]  DATETIME      NULL,
    [ModifiedDate] DATETIME      NULL,
    [IsActive]     BIT           NULL,
    PRIMARY KEY CLUSTERED ([EventId] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([EventTypeId]) REFERENCES [BQTReservation].[EventTypeMaster] ([EventTypeId])
);

