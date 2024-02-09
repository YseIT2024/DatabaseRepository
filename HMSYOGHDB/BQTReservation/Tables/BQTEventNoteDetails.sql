CREATE TABLE [BQTReservation].[BQTEventNoteDetails] (
    [BQTEventNoteDetailsId] INT           IDENTITY (1, 1) NOT NULL,
    [BookingID]             INT           NULL,
    [NotesReservation]      VARCHAR (100) NULL,
    [NotesBQTOperation]     VARCHAR (100) NULL,
    [NotesFNBOperation]     VARCHAR (100) NULL,
    [NotesKitchen]          VARCHAR (100) NULL,
    [NotesFO]               VARCHAR (100) NULL,
    [NotesHK]               VARCHAR (100) NULL,
    [NotesIT]               VARCHAR (100) NULL,
    [NotesEng]              VARCHAR (100) NULL,
    [NotesSales]            VARCHAR (100) NULL,
    [NotesOther]            VARCHAR (100) NULL,
    [CreatedBy]             INT           NULL,
    [ModifiedBy]            INT           NULL,
    [CreatedDate]           DATETIME      NULL,
    [ModifiedDate]          DATETIME      NULL,
    [IsActive]              BIT           NULL,
    PRIMARY KEY CLUSTERED ([BQTEventNoteDetailsId] ASC) WITH (FILLFACTOR = 90),
    FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID]),
    FOREIGN KEY ([BookingID]) REFERENCES [BQTReservation].[BQTBooking] ([BookingID])
);

