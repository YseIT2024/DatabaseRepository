CREATE TABLE [app].[Tab] (
    [TabID]       INT          IDENTITY (1, 1) NOT NULL,
    [TabName]     VARCHAR (50) NOT NULL,
    [DisplayText] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Tab] PRIMARY KEY CLUSTERED ([TabID] ASC) WITH (FILLFACTOR = 90)
);

