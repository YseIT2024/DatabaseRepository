CREATE TABLE [app].[Operation] (
    [OperationID] INT           NOT NULL,
    [Operation]   VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (100) NULL,
    CONSTRAINT [PK_Operation] PRIMARY KEY CLUSTERED ([OperationID] ASC) WITH (FILLFACTOR = 90)
);

