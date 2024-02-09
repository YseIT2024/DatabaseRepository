CREATE TABLE [reservation].[SalesTypes] (
    [SalesTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [SalesType]   VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_SalesTypes] PRIMARY KEY CLUSTERED ([SalesTypeID] ASC) WITH (FILLFACTOR = 90)
);

