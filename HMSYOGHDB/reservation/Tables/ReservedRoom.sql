CREATE TABLE [reservation].[ReservedRoom] (
    [ReservedRoomID]           INT      IDENTITY (1, 1) NOT NULL,
    [ReservationID]            INT      NOT NULL,
    [RoomID]                   INT      NOT NULL,
    [StandardCheckInOutTimeID] INT      NOT NULL,
    [RateCurrencyID]           INT      NOT NULL,
    [ShiftedRoomID]            INT      NULL,
    [IsActive]                 BIT      CONSTRAINT [DF_ReservedRoom_IsActive] DEFAULT ((1)) NOT NULL,
    [ModifiedDate]             DATETIME NULL,
    [UserID]                   INT      NULL,
    [ExpectedCheckIn]          DATETIME NULL,
    [ExpectedCheckOut]         DATETIME NULL,
    [ActualCheckIn]            DATETIME NULL,
    [ActualCheckOut]           DATETIME NULL,
    CONSTRAINT [PK_ReservedRoom] PRIMARY KEY CLUSTERED ([ReservedRoomID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ReservedRoom_Reservation1] FOREIGN KEY ([ReservationID]) REFERENCES [reservation].[Reservation] ([ReservationID])
);

