CREATE TABLE [general].[Language] (
    [LanguageID]  INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Language]    VARCHAR (50) NOT NULL,
    [DisplayText] VARCHAR (50) NOT NULL,
    [SortOrder]   INT          NOT NULL,
    CONSTRAINT [PK_Language] PRIMARY KEY CLUSTERED ([LanguageID] ASC) WITH (FILLFACTOR = 90)
);

