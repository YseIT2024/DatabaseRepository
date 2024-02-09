CREATE TABLE [shift].[JobTitle] (
    [JobTitleID] INT          IDENTITY (1, 1) NOT NULL,
    [JobTitle]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_JobTitle] PRIMARY KEY CLUSTERED ([JobTitleID] ASC) WITH (FILLFACTOR = 90)
);

