CREATE TABLE [app].[TabGroup] (
    [TabGroupID]   INT          IDENTITY (1, 1) NOT NULL,
    [TabID]        INT          NOT NULL,
    [TabGroupName] VARCHAR (50) NOT NULL,
    [DisplayText]  VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_TabGroup] PRIMARY KEY CLUSTERED ([TabGroupID] ASC) WITH (FILLFACTOR = 90)
);

