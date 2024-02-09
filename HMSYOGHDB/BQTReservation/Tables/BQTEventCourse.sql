CREATE TABLE [BQTReservation].[BQTEventCourse] (
    [BQTEventCourseId] INT           IDENTITY (1, 1) NOT NULL,
    [BookingID]        INT           NULL,
    [FromDate]         DATETIME      NULL,
    [FromTime]         TIME (7)      NULL,
    [ToDate]           DATETIME      NULL,
    [ToTime]           TIME (7)      NULL,
    [Course]           VARCHAR (100) NULL,
    [Remarks]          VARCHAR (255) NULL,
    [CreatedBy]        INT           NULL,
    [ModifiedBy]       INT           NULL,
    [CreatedDate]      DATETIME      NULL,
    [ModifiedDate]     DATETIME      NULL,
    [IsActive]         BIT           NULL,
    CONSTRAINT [PK__BQTEvent__ADD6E3E982434782] PRIMARY KEY CLUSTERED ([BQTEventCourseId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__BQTEventC__Booki__0426699E] FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID])
);

