CREATE TABLE [general].[NoteType] (
    [NoteTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [NoteType]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_NoteType] PRIMARY KEY CLUSTERED ([NoteTypeID] ASC) WITH (FILLFACTOR = 90)
);

