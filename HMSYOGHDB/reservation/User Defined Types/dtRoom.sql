CREATE TYPE [reservation].[dtRoom] AS TABLE (
    [ID]          INT             NULL,
    [RoomID]      INT             NULL,
    [Adults]      INT             NULL,
    [Children]    INT             NULL,
    [ExtraAdults] INT             NULL,
    [AvgRate]     DECIMAL (18, 3) NULL,
    [TotalAmount] DECIMAL (18, 3) NULL);

