CREATE TYPE [BQTReservation].[BQTFOReservationDetails] AS TABLE (
    [BookingID]     INT          NULL,
    [Arrival]       DATETIME     NULL,
    [Departure]     DATETIME     NULL,
    [RoomType]      INT          NULL,
    [NumberofRooms] INT          NULL,
    [Rate]          DECIMAL (18) NULL,
    [Total]         DECIMAL (18) NULL);

