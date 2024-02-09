CREATE TABLE [Lock].[CardState] (
    [CardCode]             VARCHAR (8) NOT NULL,
    [LastMakeCardAutoCode] INT         NULL,
    [State]                INT         NULL,
    CONSTRAINT [PK_CardState] PRIMARY KEY CLUSTERED ([CardCode] ASC)
);

