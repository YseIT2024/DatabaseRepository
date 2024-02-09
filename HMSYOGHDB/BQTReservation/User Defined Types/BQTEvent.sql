CREATE TYPE [BQTReservation].[BQTEvent] AS TABLE (
    [BookingID]     INT           NULL,
    [BookedVenueId] INT           NULL,
    [EventTypeId]   INT           NULL,
    [FromDate]      DATETIME      NULL,
    [FromTime]      VARCHAR (100) NULL,
    [ToDate]        DATETIME      NULL,
    [ToTime]        VARCHAR (100) NULL,
    [Setuprequired] VARCHAR (100) NULL,
    [Pax]           INT           NULL);

