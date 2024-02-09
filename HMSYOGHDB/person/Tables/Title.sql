CREATE TABLE [person].[Title] (
    [TitleID]  INT          IDENTITY (1, 1) NOT NULL,
    [Title]    VARCHAR (20) NOT NULL,
    [GenderID] INT          NOT NULL,
    CONSTRAINT [PK_Title] PRIMARY KEY CLUSTERED ([TitleID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Title_Gender] FOREIGN KEY ([GenderID]) REFERENCES [person].[Gender] ([GenderID])
);

