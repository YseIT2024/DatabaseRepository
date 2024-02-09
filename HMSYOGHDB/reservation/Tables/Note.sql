CREATE TABLE [reservation].[Note] (
    [NoteID]        INT           IDENTITY (1, 1) NOT NULL,
    [NoteTypeID]    INT           NOT NULL,
    [ReservationID] INT           NOT NULL,
    [Note]          VARCHAR (MAX) NOT NULL,
    [UserID]        INT           NOT NULL,
    [DateTime]      DATETIME      CONSTRAINT [DF_Note_DateTime] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Note] PRIMARY KEY CLUSTERED ([NoteID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Note_Reservation] FOREIGN KEY ([ReservationID]) REFERENCES [reservation].[Reservation] ([ReservationID])
);

