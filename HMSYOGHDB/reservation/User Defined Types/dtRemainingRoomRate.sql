CREATE TYPE [reservation].[dtRemainingRoomRate] AS TABLE (
    [ReservedRoomRateID] INT             NULL,
    [ReservedRoomID]     INT             NULL,
    [DateID]             INT             NULL,
    [RateID]             INT             NULL,
    [Amount]             DECIMAL (18, 3) NULL,
    [IsVoid]             BIT             NULL);

