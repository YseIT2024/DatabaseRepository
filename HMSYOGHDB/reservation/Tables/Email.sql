CREATE TABLE [reservation].[Email] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [EmailTypeID]  INT           NOT NULL,
    [EmailType]    NCHAR (50)    NOT NULL,
    [EmailContent] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_Email] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

