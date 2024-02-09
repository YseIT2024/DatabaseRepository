CREATE TABLE [todo].[Priority] (
    [PriorityID]    INT          IDENTITY (1, 1) NOT NULL,
    [Priority]      VARCHAR (50) NOT NULL,
    [PriorityLevel] INT          NOT NULL,
    CONSTRAINT [PK_Priority] PRIMARY KEY CLUSTERED ([PriorityID] ASC) WITH (FILLFACTOR = 90)
);

