CREATE TABLE [BQTReservation].[BQTEventDetails] (
    [BQTEventDetailsID] INT           IDENTITY (1, 1) NOT NULL,
    [BookingID]         INT           NULL,
    [BookedVenueId]     INT           NULL,
    [EventTypeId]       INT           NULL,
    [FromDate]          DATETIME      NULL,
    [FromTime]          TIME (7)      NULL,
    [ToDate]            DATETIME      NULL,
    [ToTime]            TIME (7)      NULL,
    [SetupRequired]     VARCHAR (100) NULL,
    [TotalPax]          INT           NULL,
    [CreatedBy]         INT           NULL,
    [ModifiedBy]        INT           NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedDate]      DATETIME      NULL,
    [IsActive]          BIT           NULL,
    CONSTRAINT [PK__BQTEvent__20D8DC44ED91C00D] PRIMARY KEY CLUSTERED ([BQTEventDetailsID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__BQTEventD__Booki__08EB1EBB] FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID])
);

