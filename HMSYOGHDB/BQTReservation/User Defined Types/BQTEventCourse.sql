CREATE TYPE [BQTReservation].[BQTEventCourse] AS TABLE (
    [BookingID] INT           NULL,
    [FromDate]  DATETIME      NULL,
    [ToDate]    DATETIME      NULL,
    [Course]    VARCHAR (100) NULL,
    [Remaraks]  VARCHAR (100) NULL);

