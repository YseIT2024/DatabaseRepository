CREATE TABLE [BQTReservation].[BQTMediaDetails] (
    [BQTMediaDetailsId] INT           IDENTITY (1, 1) NOT NULL,
    [BookingID]         INT           NULL,
    [RequiredMedia]     VARCHAR (100) NULL,
    [FromDate]          DATETIME      NULL,
    [ToDate]            DATETIME      NULL,
    [Remarks]           VARCHAR (255) NULL,
    [CreatedBy]         INT           NULL,
    [ModifiedBy]        INT           NULL,
    [CreatedDate]       DATETIME      NULL,
    [ModifiedDate]      DATETIME      NULL,
    [IsActive]          BIT           NULL,
    CONSTRAINT [PK__BQTMedia__2DD9A78AC9B4000B] PRIMARY KEY CLUSTERED ([BQTMediaDetailsId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__BQTMediaD__Booki__77C092B9] FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID])
);

