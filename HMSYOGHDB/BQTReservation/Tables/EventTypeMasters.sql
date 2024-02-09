CREATE TABLE [BQTReservation].[EventTypeMasters] (
    [EventTypeId]       INT           IDENTITY (1, 1) NOT NULL,
    [EventTypeName]     VARCHAR (100) NULL,
    [ParentEventTypeId] INT           NULL,
    [CreatedBy]         INT           NULL,
    [ModifiedBy]        INT           NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedDate]      DATETIME      NULL,
    [IsActive]          BIT           NULL,
    PRIMARY KEY CLUSTERED ([EventTypeId] ASC) WITH (FILLFACTOR = 90)
);

