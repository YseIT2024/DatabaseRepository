CREATE TABLE [BQTReservation].[BQTRoomReservation] (
    [BQTRoomReservationId] INT             IDENTITY (1, 1) NOT NULL,
    [BookingID]            INT             NULL,
    [ArrivalDate]          DATETIME        NULL,
    [DepartureDate]        DATETIME        NULL,
    [SubCategoryId]        INT             NULL,
    [NumberofRooms]        INT             NULL,
    [RoomRate]             DECIMAL (18, 4) NULL,
    [CreatedBy]            INT             NULL,
    [ModifiedBy]           INT             NULL,
    [CreatedDate]          DATETIME        NULL,
    [ModifiedDate]         DATETIME        NULL,
    [IsActive]             BIT             NULL,
    CONSTRAINT [PK__BQTRoomR__5ABE784B0067CBA9] PRIMARY KEY CLUSTERED ([BQTRoomReservationId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__BQTRoomRe__Booki__7E6D9048] FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID]),
    CONSTRAINT [FK__BQTRoomRe__SubCa__7D796C0F] FOREIGN KEY ([SubCategoryId]) REFERENCES [Products].[SubCategory] ([SubCategoryID])
);

