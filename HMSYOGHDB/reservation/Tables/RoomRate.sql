CREATE TABLE [reservation].[RoomRate] (
    [ReservedRoomRateID] INT             IDENTITY (1, 1) NOT NULL,
    [ReservedRoomID]     INT             NOT NULL,
    [DateID]             INT             NOT NULL,
    [RateID]             INT             NULL,
    [Rate]               DECIMAL (18, 6) NOT NULL,
    [DiscountID]         INT             NOT NULL,
    [IsVoid]             BIT             CONSTRAINT [DF_RoomRate_IsVoid] DEFAULT ((0)) NOT NULL,
    [IsActive]           BIT             CONSTRAINT [DF_RoomRate_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_RoomRate] PRIMARY KEY CLUSTERED ([ReservedRoomRateID] ASC) WITH (FILLFACTOR = 90)
);

