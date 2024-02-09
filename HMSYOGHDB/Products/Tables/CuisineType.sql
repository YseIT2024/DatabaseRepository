CREATE TABLE [Products].[CuisineType] (
    [CuisineTypeID] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]          VARCHAR (100) NULL,
    [Remarks]       VARCHAR (200) NULL,
    [CreatedBy]     INT           NULL,
    [CreateDate]    DATETIME      NULL,
    CONSTRAINT [PK__Cuisine___E893E3C1D81C78C0] PRIMARY KEY CLUSTERED ([CuisineTypeID] ASC) WITH (FILLFACTOR = 90)
);

