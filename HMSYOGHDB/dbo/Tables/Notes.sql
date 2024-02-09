CREATE TABLE [dbo].[Notes] (
    [NoteID]     INT           IDENTITY (1, 1) NOT NULL,
    [LocationID] INT           NOT NULL,
    [UserID]     INT           NOT NULL,
    [Notes]      VARCHAR (MAX) NOT NULL,
    [DateTime]   DATETIME      NOT NULL,
    [IsEnabled]  BIT           NOT NULL,
    CONSTRAINT [PK_Notes] PRIMARY KEY CLUSTERED ([NoteID] ASC) WITH (FILLFACTOR = 90)
);

