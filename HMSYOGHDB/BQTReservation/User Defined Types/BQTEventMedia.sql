CREATE TYPE [BQTReservation].[BQTEventMedia] AS TABLE (
    [BookingID]      INT           NULL,
    [MeadiaRequired] VARCHAR (100) NULL,
    [FromDate]       DATETIME      NULL,
    [ToDate]         DATETIME      NULL,
    [Remarks]        VARCHAR (100) NULL);

