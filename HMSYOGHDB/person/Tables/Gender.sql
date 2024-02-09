CREATE TABLE [person].[Gender] (
    [GenderID] INT          IDENTITY (1, 1) NOT NULL,
    [Gender]   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Gender] PRIMARY KEY CLUSTERED ([GenderID] ASC) WITH (FILLFACTOR = 90)
);

