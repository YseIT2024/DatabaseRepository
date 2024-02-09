CREATE TABLE [BQTReservation].[BQTEventOrganizer] (
    [OrganizerId]   INT           IDENTITY (1, 1) NOT NULL,
    [OrganizerName] VARCHAR (100) NULL,
    [Address]       VARCHAR (100) NULL,
    [Telephone]     VARCHAR (15)  NULL,
    [Fax]           INT           NULL,
    [Email]         VARCHAR (100) NULL,
    [MobileNumber]  VARCHAR (15)  NULL,
    [CreatedBy]     INT           NULL,
    [ModifiedBy]    INT           NULL,
    [CreatedDate]   DATETIME      NULL,
    [ModifiedDate]  DATETIME      NULL,
    [IsActive]      BIT           NULL,
    [BookingId]     INT           NULL,
    PRIMARY KEY CLUSTERED ([OrganizerId] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([BookingId]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID]),
    FOREIGN KEY ([BookingId]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID])
);

