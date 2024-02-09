CREATE TABLE [BQTReservation].[BQTEventMenu] (
    [BQTEventMenuId] INT           IDENTITY (1, 1) NOT NULL,
    [BookingID]      INT           NULL,
    [APPETIZER]      VARCHAR (100) NULL,
    [SOUP]           VARCHAR (100) NULL,
    [MAINCOURSE]     VARCHAR (100) NULL,
    [DESSERTS]       VARCHAR (100) NULL,
    [TEACOFFEE]      VARCHAR (100) NULL,
    [OTHERS]         VARCHAR (100) NULL,
    [Remarks]        VARCHAR (255) NULL,
    [CreatedBy]      INT           NULL,
    [CreatedDate]    DATETIME      NULL,
    [ModifiedDate]   DATETIME      NULL,
    [IsActive]       BIT           NULL,
    PRIMARY KEY CLUSTERED ([BQTEventMenuId] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID]),
    FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID])
);

